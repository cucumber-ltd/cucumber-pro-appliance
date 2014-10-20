#!/bin/bash
#
# Loads provisioned docker image tarballs and starts containers.
#
set -e pipefail

# Just print some status
docker --version
docker images -a -q | xargs docker rmi || true
docker info

for f in images/*.tar.gz
do
  echo "Loading $f image into docker"
  gunzip -c $f | docker load
  name=`basename $f | sed s/.tar.gz$//`
  service=/etc/systemd/system/docker-$name.service
  sudo systemctl enable $service
  rm $f
  echo "Done loading $f."
done
