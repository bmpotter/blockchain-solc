# solc build

ARCH=$(shell uname -m)
HOST_ARCH=$(shell uname -m)
TAG=$(shell ./version.sh)
PACKAGE=solc
IMAGE=$(PACKAGE)
BUILDIMAGE=$(PACKAGE)build
CACHE_FLAG=--no-cache
CACHE_FLAG=

# restore flag if flag missing, but image in docker
$(shell ./flag.sh $(BUILDIMAGE) $(ARCH) $(TAG))

default: solc soltest

build: $(BUILDIMAGE)-$(ARCH)-$(TAG).flag

$(BUILDIMAGE)-$(ARCH)-$(TAG).dockerfile: Dockerfile.build.$(ARCH) Dockerfile.build
	cat Dockerfile.build.$(ARCH) Dockerfile.build >$@

$(BUILDIMAGE)-$(ARCH)-$(TAG).flag: $(BUILDIMAGE)-$(ARCH)-$(TAG).dockerfile
	docker build --build-arg VERSION=$(TAG) $(CACHE_FLAG) -t $(ARCH)/$(BUILDIMAGE):$(TAG) -f $< .
	docker tag $(ARCH)/$(BUILDIMAGE):$(TAG) ${ARCH}/$(BUILDIMAGE):latest
	touch $@

solc: $(BUILDIMAGE)-$(ARCH)-$(TAG).flag
	docker run --rm -it -v $(PWD):/outside $(ARCH)/$(BUILDIMAGE):$(TAG) /bin/bash -c "cp /usr/local/bin/$@ /outside/"

soltest: $(BUILDIMAGE)-$(ARCH)-$(TAG).flag
	docker run --rm -it -v $(PWD):/outside $(ARCH)/$(BUILDIMAGE):$(TAG) /bin/bash -c "cp /usr/local/bin/$@ /outside/"

install: solc soltest
	cp -vf $^ /usr/local/bin/

clean:
	rm -rf *.flag *.dockerfile solc soltest

distclean: clean

dockerclean:
	docker rmi $(ARCH)/$(BUILDIMAGE):latest $(ARCH)/$(BUILDIMAGE):$(TAG) || true

realclean: distclean dockerclean
	docker images -f dangling=true -q | xargs docker rmi || true

