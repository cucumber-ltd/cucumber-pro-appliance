#!/bin/bash
#
# This script pulls down docker images and exports them as tarballs so that
# they can be provisioned onto the VM and loaded into docker. See template.json
# and common/cloud-config.yaml
#

APPLIANCE_VERSION    = $(shell git rev-parse HEAD)

CUCUMBER_PRO_VERSION = $(shell head versions/cucumber-pro)
METAREPO_VERSION		 = $(shell head versions/metarepo)
MONGO_VERSION				= $(shell head versions/mongo)
POSTGRES_VERSION		 = $(shell head versions/postgres)
REDIS_VERSION				= $(shell head versions/redis)
REPOS_VERSION				= $(shell head versions/repos)

pull_squashed_image = \
	curl -L -f https://cucumberltd+appliancebuilder:$(QUAY_TOKEN)@quay.io/c1/squash/cucumberltd/$(1)/$(2) -o $(3)

main: output-coreos/packer-coreos.vmx

images: images/cucumber-pro.tar.gz \
				images/metarepo.tar.gz \
				images/mongo.tar.gz \
				images/postgres.tar.gz \
				images/redis.tar.gz \
        images/repos.tar.gz

images/mongo.tar.gz: versions/mongo
	docker pull mongo:$(MONGO_VERSION)
	docker save mongo:$(MONGO_VERSION) | gzip  > $@

images/postgres.tar.gz: versions/postgres
	docker pull postgres:$(POSTGRES_VERSION)
	docker save postgres:$(POSTGRES_VERSION) | gzip  > $@

images/redis.tar.gz: versions/redis
	docker pull redis:$(REDIS_VERSION)
	docker save redis:$(REDIS_VERSION) | gzip > $@

images/metarepo.tar.gz: versions/metarepo
	$(call pull_squashed_image,metarepo,$(METAREPO_VERSION),$@)

images/repos.tar.gz: versions/repos
	$(call pull_squashed_image,repos,$(REPOS_VERSION),$@)

images/cucumber-pro.tar.gz: versions/cucumber-pro
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

appliance/cucumber-pro-appliance-$(APPLIANCE_VERSION).tgz: output-coreos/packer-coreos.vmx
	mkdir -p appliance
	tar cvzf $@ output-coreos

publish-appliance: appliance/cucumber-pro-appliance-$(APPLIANCE_VERSION).tgz
	s3cmd put appliance/cucumber-pro-appliance-$(APPLIANCE_VERSION).tgz s3://cucumber-pro-appliance
.PHONY: publish-appliance

clean:
	rm -rf output-coreos
.PHONY: clean

clobber: clean
	rm -rf images/*.tar.gz appliance
.PHONY: clobber
