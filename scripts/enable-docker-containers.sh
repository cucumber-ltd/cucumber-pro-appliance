#!/bin/bash
#
# Loads provisioned docker image tarballs and starts containers.
#
set -e pipefail

docker --version
# Remove all images to avoid weird btrfs-related bug
docker images -a -q | xargs docker rmi || true
docker info

# We'll install metarepo the old way for now. Work around btrfs bug.
#rm -rf images/metarepo.tar.gz
#docker pull quay.io/cucumberltd/metarepo:5756343f648c362e9c5a475e3ba5e0499df7844b

for f in images/*.tar.gz
do
  echo "Loading $f image into docker"
  gunzip -c $f | nice -n 20 docker load
  name=`basename $f | sed s/.tar.gz$//`
  service=/etc/systemd/system/docker-$name.service
  sudo systemctl enable $service
  rm $f
  echo "Done loading $f. Sleep to help btrfs..."
done
