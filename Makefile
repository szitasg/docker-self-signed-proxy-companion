.PHONY:help build
.DEFAULT_GOAL=help

ARCH ?= amd64

help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build docker image
	docker build --no-cache --build-arg ARCH=$(ARCH) -t szitasg/self-signed-proxy-companion:1.0.0 .
