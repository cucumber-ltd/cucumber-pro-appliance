#!/bin/sh
DOCKER_TAG=$1
/usr/bin/docker run --rm \
  --name postgres \
  -p 5432:5432 \
  -v /core/core/volumes/postgres/data:/var/lib/postgresql/data \
  postgres:$DOCKER_TAG
