#!/bin/sh
DOCKER_TAG=$1
/usr/bin/docker run --rm \
  --name cucumber-pro \
  -p 3000:3000 \
  --env-file `dirname $0`/common.env \
  --link mongo:mongo \
  --link redis:redis \
  --link metarepo:metarepo \
  quay.io/cucumberltd/cucumber-pro:$DOCKER_TAG
