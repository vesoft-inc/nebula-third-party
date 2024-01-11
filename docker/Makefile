tags=centos-7 centos-8 rockylinux-8 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2204

all: $(tags)
.PHONY: all

print:
	@echo $(tags)

build-%: buildx/%.Dockerfile
	@echo '******************' Build Nebula Third Party Docker For $*-$(arch) '********************'
	@docker build --no-cache -t vesoft/third-party-build:$* -f buildx/$*.Dockerfile .

push-%: build-%
	@echo '******************' Pushing image $* '********************'
	@docker push vesoft/third-party-build:$*

%: push-% ;
