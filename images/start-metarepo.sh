#!/bin/sh
DOCKER_TAG=$1
/usr/bin/docker run --rm \
  --name metarepo \
  -p 5000:5000 \
  --env-file `dirname $0`/common.env \
  --link mongo:mongo \
  --link postgres:postgres \
  quay.io/cucumberltd/metarepo:$DOCKER_TAG
