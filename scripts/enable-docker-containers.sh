#!/bin/bash
#
# Loads provisioned docker image tarballs and starts containers.
#
# Can't make this work during provisioning, so make it a manual step.
#
set -e pipefail

gunzip -c images/mongo.tar.gz | docker load
gunzip -c images/postgres.tar.gz | docker load
gunzip -c images/redis.tar.gz | docker load
docker images
sudo systemctl enable /etc/systemd/system/docker-mongo.service
sudo systemctl enable /etc/systemd/system/docker-postgres.service
sudo systemctl enable /etc/systemd/system/docker-redis.service
