#!/bin/bash
#
# This script pulls down docker images and exports them as tarballs so that
# they can be provisioned onto the VM and loaded into docker. See template.json
# and common/cloud-config.yaml
#

MONGO_VERSION = 2.6.4
POSTGRES_VERSION = 9.4
REDIS_VERSION = 2.8.13

# This version is a git sha
METAREPO_VERSION = 5756343f648c362e9c5a475e3ba5e0499df7844b
REPOS_VERSION = 1f46a0f9dde78e29b1708b3660ab4d92a78611a8

QUAY_ACCOUNT = cucumberltd+appliancebuilder

main: output-coreos/packer-coreos.vmx

images: images/mongo.tar.gz \
				images/postgres.tar.gz \
				images/redis.tar.gz \
				images/metarepo.tar.gz \
				images/repos.tar.gz

images/mongo.tar.gz:
	docker pull mongo:$(MONGO_VERSION)
	docker save mongo:$(MONGO_VERSION) | gzip  > $@

images/postgres.tar.gz:
	docker pull postgres:$(POSTGRES_VERSION)
	docker save postgres:$(POSTGRES_VERSION) | gzip  > $@

images/redis.tar.gz:
	docker pull redis:$(REDIS_VERSION)
	docker save redis:$(REDIS_VERSION) | gzip > $@

images/metarepo.tar.gz: check_token
	curl -L -f https://$(QUAY_ACCOUNT):$(QUAY_TOKEN)@quay.io/c1/squash/cucumberltd/metarepo/$(METAREPO_VERSION) -o $@

images/repos.tar.gz: check_token
	curl -L -f https://$(QUAY_ACCOUNT):$(QUAY_TOKEN)@quay.io/c1/squash/cucumberltd/repos/$(REPOS_VERSION) -o $@

# TODO: Add more

output-coreos/packer-coreos.vmx: images
	packer build template.json

check_token:
ifndef QUAY_TOKEN
	$(error QUAY_TOKEN is undefined)
endif
.PHONY: check_token

clean:
	rm -rf output-coreos
.PHONY: clean

clobber: clean
	rm -rf images/*.tar.gz
.PHONY: clobber
