SHELL = /usr/bin/env bash -xe

PWD := $(shell pwd)

build: lib/ncdapi.sh
	@rm -rf target
	@mkdir target
	@cp lib/ncdapi.sh ./target/
	@cp src/ncddns.sh ./target/
	@cd target && zip function.zip ncdapi.sh ncddns.sh && cd -

lib/ncdapi.sh:
	@curl -L -o lib/ncdapi.sh https://github.com/adulescentulus/ncdapi/raw/master/ncdapi.sh

publish:
	@$(PWD)/publish.sh

publish-staging:
	@$(PWD)/publish-staging.sh
