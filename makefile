SHELL=/bin/bash
timestamp := $(shell date +"%Y-%m-%d-%H-%M")

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
.DEFAULT_GOAL := push
.PHONY: push
## push docker-registry images
push: bold = $(shell tput bold; tput setaf 3)
push: reset = $(shell tput sgr0)

push:
	git pull
	VERSION=${timestamp} docker-compose -f docker-compose.yml -f docker-compose.dev.yml build;
	VERSION=${timestamp} docker-compose push
	git tag --create $(timestamp)
	git push origin --tags
	@echo '$(bold)${timestamp}$(reset)'


################################################################################
.PHONY: restore
## restore the indicies (backup folder)
restore:
	docker-compose run --rm -v "$(CURDIR)/backup:/mount/backups/my_backup" curator restore

################################################################################
.PHONY: backup
## backup the indicies (backup folder)
backup:
	docker-compose run --rm  -v "$(CURDIR)/backup:/mount/backups/my_backup" curator manual_backup

################################################################################
.PHONY: certificate
## pull docker-registry images
certificate:
	cd .env-files && ./certificate.sh
