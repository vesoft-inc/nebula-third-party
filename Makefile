tags=centos-7 centos-8 rockylinux-8 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2204

all: $(tags)

.PHONY: all

print:
	@echo $(tags)

docker_cmd := docker run -v $$PWD/docker/run.sh:/usr/src/third-party/run.sh -v $$PWD/build/packages:/data
ifneq ($(USE_GCC_VERSIONS),)
	docker_cmd += -e USE_GCC_VERSIONS=$(USE_GCC_VERSIONS)
endif

%:
	@echo '******************' Build Nebula Third Party For $* '********************'
	@$(docker_cmd) --rm -it vesoft/third-party-build:$* ./run.sh
