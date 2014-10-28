#!/bin/sh
DOCKER_TAG=$1
/usr/bin/docker run --rm \
  --name redis \
  -p 6379:6379 \
  -v /home/core/volumes/redis/data:/data \
  redis:$DOCKER_TAG \
  redis-server --appendonly yes
