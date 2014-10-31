# Cucumber Pro Appliance

This project builds the Cucumber Pro Appliance for [VMWare][] using [Packer][].
It builds a machine running [Core OS][] with several [Docker][] images pre-installed.

## Requirements

* [Docker][] >= 1.2.0
  * On OS X, use https://github.com/boot2docker/osx-installer/releases
* [Packer][] >= 0.7.1
* [VMWare Fusion][] >= 7.0.0
* [VMWare OVF Tool][] >= 4.0.0

The `ovftool` command isn't on your `PATH` by default - you should add it:

```sh
export PATH=$PATH:/Applications/VMware\ OVF\ Tool
ovftool --version
```

## Building

Find the `QUAY_TOKEN` for the
[cucumberltd+appliancebuilder](https://quay.io/organization/cucumberltd/admin?tab=robots&showRobot=cucumberltd%2Bappliancebuilder)
robot account so that you can pull down our private docker images.

Then build the appliance:

```sh
QUAY_TOKEN=... make
```

This will provide you with a VM in `cucumber-pro-appliance`

## Publish appliance to S3

Publishing is done with [s3cmd](http://s3tools.org/s3cmd) and generation of
the download URL uses [the official AWS SDK Ruby gem](http://aws.amazon.com/sdk-for-ruby/). run
In order for these to work you have to set up your S3 credentials in:

* `~/.s3cfg` (run `s3cmd --configure` to create this file)
* `~/.aws/credentials` (see [this link](http://docs.aws.amazon.com/AWSSdkDocsRuby/latest/DeveloperGuide/ruby-dg-setup.html#set-up-creds))

Alternatively you can use environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

```
QUAY_TOKEN=... make publish
```

This will upload the appliance `.tar.gz` to S3 and print out a download link
that is valid for 7 days.

To regenerate the download URL, just run `make publish` again.

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

[VMWare Fusion]: http://www.vmware.com/uk/products/fusion
[VMWare OVF Tool]: https://www.vmware.com/support/developer/ovf/
[Core OS]: https://coreos.com/
[Docker]: https://www.docker.com/
[Packer]: http://www.packer.io/
