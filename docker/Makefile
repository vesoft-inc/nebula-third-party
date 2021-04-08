arch=$(shell uname -m)
tags=centos-7 centos-8 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2010

all: $(tags)
.PHONY: all

print:
	@echo $(tags)

build-%: $(arch)/%.Dockerfile
	@echo '******************' Build Nebula Third Party Docker For $*-$(arch) '********************'
	@docker build --no-cache -t dutor/third-party-build:$*-$(arch) -f $(arch)/$*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing image $*-$(arch) '********************'
	@docker push dutor/third-party-build:$*-$(arch)

%: push-% ;
