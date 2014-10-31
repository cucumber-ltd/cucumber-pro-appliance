#!/bin/bash
#
# This script pulls down docker images and exports them as tarballs so that
# they can be provisioned onto the VM and loaded into docker. See template.json
# and common/cloud-config.yaml
#

APPLIANCE_VERSION    = $(shell git rev-parse HEAD)

CUCUMBER_PRO_VERSION = $(shell head versions/cucumber-pro)
METAREPO_VERSION     = $(shell head versions/metarepo)
MONGO_VERSION        = $(shell head versions/mongo)
POSTGRES_VERSION     = $(shell head versions/postgres)
REDIS_VERSION        = $(shell head versions/redis)
REPOS_VERSION        = $(shell head versions/repos)

pull_squashed_image = \
	curl -L -f https://cucumberltd+appliancebuilder:$(QUAY_TOKEN)@quay.io/c1/squash/cucumberltd/$(1)/$(2) -o $(3)

main: cucumber-pro-appliance/cucumber-pro-appliance-$(APPLIANCE_VERSION).ovf

images: images/cucumber-pro-$(CUCUMBER_PRO_VERSION).tar.gz \
				images/metarepo-$(METAREPO_VERSION).tar.gz \
				images/mongo-$(MONGO_VERSION).tar.gz \
				images/postgres-$(POSTGRES_VERSION).tar.gz \
				images/redis-$(REDIS_VERSION).tar.gz \
        images/repos-$(REPOS_VERSION).tar.gz

images/mongo-$(MONGO_VERSION).tar.gz: versions/mongo
	docker pull mongo:$(MONGO_VERSION)
	docker save mongo:$(MONGO_VERSION) | gzip  > $@

images/postgres-$(POSTGRES_VERSION).tar.gz: versions/postgres
	docker pull postgres:$(POSTGRES_VERSION)
	docker save postgres:$(POSTGRES_VERSION) | gzip  > $@

images/redis-$(REDIS_VERSION).tar.gz: versions/redis
	docker pull redis:$(REDIS_VERSION)
	docker save redis:$(REDIS_VERSION) | gzip > $@

images/metarepo-$(METAREPO_VERSION).tar.gz: versions/metarepo
	$(call pull_squashed_image,metarepo,$(METAREPO_VERSION),$@)

images/repos-$(REPOS_VERSION).tar.gz: versions/repos
	$(call pull_squashed_image,repos,$(REPOS_VERSION),$@)

images/cucumber-pro-$(CUCUMBER_PRO_VERSION).tar.gz: versions/cucumber-pro
	$(call pull_squashed_image,cucumber-pro,$(CUCUMBER_PRO_VERSION),$@)

common/cloud-config.yaml: common/cloud-config-template.yaml
	cp common/cloud-config-template.yaml $@
	perl -pi -e 's/MONGO_VERSION/$(MONGO_VERSION)/g' $@
	perl -pi -e 's/POSTGRES_VERSION/$(POSTGRES_VERSION)/g' $@
	perl -pi -e 's/REDIS_VERSION/$(REDIS_VERSION)/g' $@
	perl -pi -e 's/METAREPO_VERSION/$(METAREPO_VERSION)/g' $@
	perl -pi -e 's/REPOS_VERSION/$(REPOS_VERSION)/g' $@
	perl -pi -e 's/CUCUMBER_PRO_VERSION/$(CUCUMBER_PRO_VERSION)/g' $@

vmx/cucumber-pro-appliance.vmx: images common/cloud-config.yaml
	packer build template.json

cucumber-pro-appliance/cucumber-pro-appliance-$(APPLIANCE_VERSION).ovf: vmx/cucumber-pro-appliance.vmx
	mkdir -p `dirname $@`
	ovftool $< $@

cucumber-pro-appliance-$(APPLIANCE_VERSION).tar.gz: cucumber-pro-appliance/cucumber-pro-appliance-$(APPLIANCE_VERSION).ovf
	tar cvzf $@ `dirname $<`

cucumber-pro-appliance-$(APPLIANCE_VERSION).tar.gz.uploaded: cucumber-pro-appliance-$(APPLIANCE_VERSION).tar.gz
	s3cmd put $< s3://cucumber-pro-appliance
	touch $@

publish: cucumber-pro-appliance-$(APPLIANCE_VERSION).tar.gz.uploaded Gemfile.lock
	@echo `./generate-download-url cucumber-pro-appliance-$(APPLIANCE_VERSION).tar.gz`
.PHONY: publish

Gemfile.lock: Gemfile
	bundle install

clean:
	rm -rf cucumber-pro-appliance* vmx
.PHONY: clean

clobber: clean
	git clean -dfx
.PHONY: clobber
