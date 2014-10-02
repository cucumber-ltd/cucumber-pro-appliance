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
ssh -i common/coreos.pub core@<IP>
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

### Running

The next stage is to import it into your VM host. You also need to mount the
`configdrive.iso` image from above.

[Core OS]: https://coreos.com
[Packer]: http://www.packer.io
[config-drive]: https://github.com/coreos/coreos-cloudinit/blob/master/Documentation/config-drive.md
[See here]: http://wiki.osdev.org/Mkisofs
[cloud-config]: https://coreos.com/docs/cluster-management/setup/cloudinit-cloud-config/
