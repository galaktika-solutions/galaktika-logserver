SHELL=/bin/bash

timestamp := $(shell date +"%Y-%m-%d-%H-%M")
env := $(shell cat .env | grep "MV2_ENV")
usr := $(shell id -u):$(shell id -g)

################################################################################
# self documenting makefile
################################################################################
.DEFAULT_GOAL := help
.PHONY: help
## print available targets
help: bold = $(shell tput bold; tput setaf 3)
help: reset = $(shell tput sgr0)
help:
	@echo
	@sed -nr \
		-e '/^## /{s/^## /    /;h;:a;n;/^## /{s/^## /    /;H;ba};' \
		-e '/^[[:alnum:]_\-]+:/ {s/(.+):.*$$/$(bold)\1$(reset):/;G;p};' \
		-e 's/^[[:alnum:]_\-]+://;x}' ${MAKEFILE_LIST}
	@echo

################################################################################
.PHONY: build

## build all docker images (use DEV)
build:
	 docker-compose -f docker-compose.yml -f docker-compose.dev.yml build

################################################################################
.PHONY: restore

restore:


################################################################################
.PHONY: backup

backup:

################################################################################
.PHONY: push_prod

push_prod:


################################################################################
.PHONY: push_test

push_test:
	# REGISTRY_PREFIX=test docker-compose -f docker-compose.yml -f docker-compose.dev.yml build
	# REGISTRY_PREFIX=test REGISTRY_TAG=$(timestamp) docker-compose -f docker-compose.yml -f docker-compose.dev.yml build
	# docker-compose run --rm django test_keepdb
	# docker-compose run --rm django build_test
	# REGISTRY_PREFIX=test docker-compose push
	# REGISTRY_PREFIX=test REGISTRY_TAG=$(timestamp) docker-compose push
	# git tag --create test-$(timestamp)
	# git push origin --tags
	# docker-compose down


################################################################################
.PHONY: pull

pull:

################################################################################
.PHONY: pull-up-d

pull-up-d: pull
	docker-compose up -d
