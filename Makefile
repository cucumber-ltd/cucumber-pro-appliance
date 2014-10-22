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
METAREPO_VERSION = 6d04e8c8b9f1311972e255c24feefcd85c210376
REPOS_VERSION = 1901ec832fb0978571803670f4808923f048fb1c
CUCUMBER_PRO_VERSION = e12bbe4c4d73402a3947b93ee9338eb9cd44e9f2

pull_squashed_image = \
	curl -L -f https://cucumberltd+appliancebuilder:$(QUAY_TOKEN)@quay.io/c1/squash/cucumberltd/$(1)/$(2) -o $(3)

main: output-coreos/packer-coreos.vmx

images: images/mongo.tar.gz \
				images/postgres.tar.gz \
				images/redis.tar.gz \
        images/repos.tar.gz \
        images/metarepo.tar.gz \
				images/cucumber-pro.tar.gz

images/mongo.tar.gz:
	docker pull mongo:$(MONGO_VERSION)
	docker save mongo:$(MONGO_VERSION) | gzip  > $@

images/postgres.tar.gz:
	docker pull postgres:$(POSTGRES_VERSION)
	docker save postgres:$(POSTGRES_VERSION) | gzip  > $@

images/redis.tar.gz:
	docker pull redis:$(REDIS_VERSION)
	docker save redis:$(REDIS_VERSION) | gzip > $@

images/metarepo.tar.gz: Makefile
	$(call pull_squashed_image,metarepo,$(METAREPO_VERSION),$@)

images/repos.tar.gz: Makefile
	$(call pull_squashed_image,repos,$(REPOS_VERSION),$@)

images/cucumber-pro.tar.gz: Makefile
	$(call pull_squashed_image,cucumber-pro,$(CUCUMBER_PRO_VERSION),$@)

common/cloud-config.yaml: common/cloud-config-template.yaml Makefile
	cp common/cloud-config-template.yaml $@
	perl -pi -e 's/MONGO_VERSION/$(MONGO_VERSION)/g' $@
	perl -pi -e 's/POSTGRES_VERSION/$(POSTGRES_VERSION)/g' $@
	perl -pi -e 's/REDIS_VERSION/$(REDIS_VERSION)/g' $@
	perl -pi -e 's/METAREPO_VERSION/$(METAREPO_VERSION)/g' $@
	perl -pi -e 's/REPOS_VERSION/$(REPOS_VERSION)/g' $@
	perl -pi -e 's/CUCUMBER_PRO_VERSION/$(CUCUMBER_PRO_VERSION)/g' $@

output-coreos/packer-coreos.vmx: images common/cloud-config.yaml
	packer build template.json

clean:
	rm -rf output-coreos
.PHONY: clean

clobber: clean
	rm -rf images/*.tar.gz
.PHONY: clobber
