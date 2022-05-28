SHELL = /usr/bin/env bash -xe

PWD := $(shell pwd)

build:
	@rm -rf target
	@mkdir target
	@cp lib/cf-ddns.sh ./target/
	@cp src/ncddns.sh ./target/
	@cd target && zip function.zip cf-ddns.sh ncddns.sh && cd -

publish:
	@$(PWD)/publish.sh

publish-staging:
	@$(PWD)/publish-staging.sh
