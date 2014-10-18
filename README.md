# Cucumber Pro Appliance

This project builds the Cucumber Pro Appliance for [VMWare][] using [Packer][].
It builds a machine running [Core OS][] with several [Docker][] images pre-installed.

## Requirements

* [Docker][] >= 1.2.0
* [Packer][] >= 0.7.1
* [VMWare][] Fusion >= 7.0.0

## Building

First, pull down the docker images:

```sh
make
```

```sh
packer build template.json
```

This will provide you with a compressed archive of the VM.

## SSH into the box

First, change permissions on the private key (git won't store this):

```sh
chmod 600 common/coreos
```

The IP address of the machine should display above the login prompt.

```
ssh -i common/coreos core@<IP>
```

[VMWare]: http://www.vmware.com/
[Core OS]: https://coreos.com/
[Docker]: https://www.docker.com/
[Packer]: http://www.packer.io/
