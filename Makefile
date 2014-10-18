#!/bin/bash
#
# This script pulls down docker images and exports them as tarballs so that
# they can be provisioned onto the VM and loaded into docker. See template.json
# and common/cloud-config.yaml
#

MONGO_VERSION = 2.6.4
POSTGRES_VERSION = 9.4
REDIS_VERSION = 2.8.13
METAREPO_VERSION = 5756343f648c362e9c5a475e3ba5e0499df7844b

images: images/mongo.tar.gz images/postgres.tar.gz images/redis.tar.gz images/metarepo.tar.gz

images/mongo.tar.gz:
	docker pull mongo:$(MONGO_VERSION)
	docker save mongo:$(MONGO_VERSION) | gzip  > $@

images/postgres.tar.gz:
	docker pull postgres:$(POSTGRES_VERSION)
	docker save postgres:$(POSTGRES_VERSION) | gzip  > $@

images/redis.tar.gz:
	docker pull redis:$(REDIS_VERSION)
	docker save redis:$(REDIS_VERSION) | gzip > $@

images/metarepo.tar.gz:
	docker pull quay.io/cucumberltd/metarepo:$(METAREPO_VERSION)
	docker save quay.io/cucumberltd/metarepo:$(METAREPO_VERSION) | gzip > $@
