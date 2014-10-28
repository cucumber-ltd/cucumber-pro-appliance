#!/bin/sh
DOCKER_TAG=$1
/usr/bin/docker run --rm \
  --name mongo \
  -p 27017:27017 \
  -v /home/core/volumes/mongo/data:/data/db \
  mongo:$DOCKER_TAG
