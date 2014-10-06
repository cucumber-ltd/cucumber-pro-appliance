#!/bin/bash
#
# Loads provisioned docker image tarballs and starts containers.
#
# Can't make this work during provisioning, so make it a manual step.
#
set -e pipefail

# remove all images to avoid weird btrfs-related bug:
docker images -a -q | xargs docker rmi
echo "Loading mongo"
gunzip -c images/mongo.tar.gz > images/mongo.tar
docker load -i images/mongo.tar
echo "Loading postgres"
gunzip -c images/postgres.tar.gz > images/postgres.tar
docker load -i images/postgres.tar
echo "Loading redis"
gunzip -c images/redis.tar.gz > images/redis.tar
docker load -i images/redis.tar
docker images
sudo systemctl enable /etc/systemd/system/docker-mongo.service
sudo systemctl enable /etc/systemd/system/docker-postgres.service
sudo systemctl enable /etc/systemd/system/docker-redis.service
rm images/*.tar
