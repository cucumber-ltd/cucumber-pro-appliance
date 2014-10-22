#!/bin/bash
#
# This script pulls down docker images and exports them as tarballs so that
# they can be provisioned onto the VM and loaded into docker. See template.json
# and common/cloud-config.yaml
#

MONGO_VERSION = 2.7.7
POSTGRES_VERSION = 9.4
REDIS_VERSION = 2.8.17

# This version is a git sha
METAREPO_VERSION = 5756343f648c362e9c5a475e3ba5e0499df7844b
REPOS_VERSION = 1f46a0f9dde78e29b1708b3660ab4d92a78611a8
CUCUMBER_PRO_VERSION = e21cc06370a303f4d64d09d18bbe59a8ae8fdd39

pull_squashed_image = \
	curl -L -f https://cucumberltd+appliancebuilder:$(QUAY_TOKEN)@quay.io/c1/squash/cucumberltd/$(1)/$(2) -o $(3)

main: output-coreos/packer-coreos.vmx

images: images/mongo.tar.gz \
				images/postgres.tar.gz \
				images/redis.tar.gz \
        images/repos.tar.gz \
        images/metarepo.tar.gz

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
	$(call pull_squashed_image,metarepo,$(METAREPO_VERSION),$@)

images/repos.tar.gz:
	$(call pull_squashed_image,repos,$(REPOS_VERSION),$@)

images/cucumber-pro.tar.gz:
	$(call pull_squashed_image,cucumber-pro,$(CUCUMBER_PRO_VERSION),$@)

output-coreos/packer-coreos.vmx: images
	packer build template.json

clean:
	rm -rf output-coreos
.PHONY: clean

clobber: clean
	rm -rf images/*.tar.gz
.PHONY: clobber
