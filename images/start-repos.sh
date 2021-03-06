#!/bin/sh
DOCKER_TAG=$1
/usr/bin/docker run --rm \
  --name repos \
  -p 5001:5001 \
  --env-file `dirname $0`/common.env \
  --link mongo:mongo \
  --link redis:redis \
  --link metarepo:metarepo \
  quay.io/cucumberltd/repos:$DOCKER_TAG
