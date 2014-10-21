# Cucumber Pro Appliance

This project builds the Cucumber Pro Appliance for [VMWare][] using [Packer][].
It builds a machine running [Core OS][] with several [Docker][] images pre-installed.

## Requirements

* [Docker][] >= 1.2.0
  * On OS X, use https://github.com/boot2docker/osx-installer/releases
* [Packer][] >= 0.7.1
* [VMWare][] Fusion >= 7.0.0

## Building

Find the `QUAY_TOKEN` for the
[cucumberltd+appliancebuilder](https://quay.io/organization/cucumberltd/admin?tab=robots&showRobot=cucumberltd%2Bappliancebuilder)
robot account so that you can pull down our private docker images.

Then build the appliance:

```sh
QUAY_TOKEN=... make
```

This will provide you with a VM in `output-coreos`

## SSH into the box

First, change permissions on the private key (git won't store this):

```sh
chmod 600 common/coreos
```

The IP address of the machine should display above the login prompt.

```sh
ssh -i common/coreos core@<IP>
```

## How the build works

* `make` downloads all docker image tarballs to `images` on the host
* Packer fetches vanilla CoreOS and boots it
* Packer configures/upgrades CoreOS using `common/coreos-install` that reads `common/cloud-config.yml`
  * `common/cloud-config.yml` describes the systemd-managed services on CoreOS
  * All services are initially disabled and will be enabled during provisioning
  * The `coreos` and `coreos.pub` files are SSH keys for `ssh` into the VM from host
* Packer provisions the box
  * Uploading docker image tarballs and scripts from `images` to CoreOS
  * Runs `scripts/enable-docker-containers.sh` on CoreOS
    * This loads each docker image tarball into docker
    * Enables the associated service
    * Removes the tarball
* We're done! The VM is in `output-coreos`

[VMWare]: http://www.vmware.com/
[Core OS]: https://coreos.com/
[Docker]: https://www.docker.com/
[Packer]: http://www.packer.io/
