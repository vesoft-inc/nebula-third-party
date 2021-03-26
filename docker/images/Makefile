arch=$(shell uname -m)
tags=$(addsuffix -$(arch), centos-7 centos-8 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2010)

all: $(tags)

print:
	@echo $(tags)

build-%: %.Dockerfile
	@echo '******************' Build image $* '********************'
	@docker build --no-cache -t dutor/third-party-build:$* -f $*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing image $* '********************'
	@docker push dutor/third-party-build:$*

%: push-% ;
