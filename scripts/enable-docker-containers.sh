#!/bin/bash
#
# Loads provisioned docker image tarballs and starts containers.
#
set -e pipefail

# Just print some status
docker --version
docker info

for f in images/*.tar.gz
do
  echo "Loading $f image into docker"
  docker load < $f
  name=`basename $f | sed s/.tar.gz$//`
  # This script is defined in cloud-config.yaml
  service=/etc/systemd/system/docker-$name.service
  # Enable the service now that the docker image it will start is loaded into docker
  sudo systemctl enable $service
  rm $f
  echo "Done loading $f."
done
