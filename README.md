# packer-coreos

A template for installing [Core OS][] using [Packer][], with a machine archive
as it's output.

## Requirements

* [Packer][] >= 0.7.1

## Usage

### Building

The simplest way is to build a Core OS VM by doing:

```sh
packer build template.json
```

This will provide you with a compressed archive of the VM.

### SSH into the box

First, change permissions on the private key (git won't store this):

```sh
chmod 600 common/coreos
```

The IP address of the machine should display above the login prompt.

```
ssh -i common/coreos core@<IP>
```

### Configuration

Once you have a Core OS image, you need to provide the cluster configuration.
This is best provided by a ["config drive"][config-drive] image, which contains
the full `cloud-config` configuration file. See the Core OS docs entry for
['Using Cloud-Config'][cloud-config].

Using this example `cloud-config`, which brings up the basic services:

```yaml
#cloud-config

coreos:
    etcd:
        # token for each unique cluster
        discovery: https://discovery.etcd.io/<token>
        # ip address for this node
        addr: 0.0.0.0:4001
        peer-addr: 0.0.0.0:7001
    fleet:
        public-ip: 0.0.0.0   # used for fleetctl ssh command
    units:
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start
```

You should replace the discovery URL and IPs with real ones. And then build
the disc image:

```sh
mkdir -p /tmp/new-drive/openstack/latest
cp cloud-config /tmp/new-drive/openstack/latest/user_data
mkisofs -R -V config-2 -o configdrive.iso /tmp/new-drive
rm -r /tmp/new-drive
```

(`mkisofs` is in Homebrew for OS X under `cdrtools`. An equivalent fork is
available for Debian/Ubuntu as `genisoimage`. [See here][].)

### Question

- Why pulling down CoreOS twice?? Once by packer and once in coreos-install. Is it upgrading? Configuring?

### TODO

The docker images are big, so we want to upload them to the machine as part of the
provisioning process. We have a Makefile that can pull them down on the host,
and then they can be uploaded in `template.json`.

The problem is that we're getting an error when we're trying to `docker load` the
images. Maybe the solution is in here somewhere:

* https://coreos.com/docs/cluster-management/setup/mounting-storage/
* https://coreos.com/docs/launching-containers/building/customizing-docker/
* https://coreos.com/docs/running-coreos/platforms/vmware/

For now we can work around it by SSHing into the box and run:

    scripts/enable-docker-containers.sh

### Running

The next stage is to import it into your VM host. You also need to mount the
`configdrive.iso` image from above.

[Core OS]: https://coreos.com
[Packer]: http://www.packer.io
[config-drive]: https://github.com/coreos/coreos-cloudinit/blob/master/Documentation/config-drive.md
[See here]: http://wiki.osdev.org/Mkisofs
[cloud-config]: https://coreos.com/docs/cluster-management/setup/cloudinit-cloud-config/
