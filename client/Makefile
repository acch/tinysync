DOCKER     := /bin/podman
IMAGE_NAME := acch/tinysync
IMAGE_TAG  := client-test

BUILDFLAGS := --no-cache --pull

default: build test

build:
	$(DOCKER) build $(BUILDFLAGS) -t docker.io/$(IMAGE_NAME):$(IMAGE_TAG) .

test:
	$(DOCKER) run --rm docker.io/$(IMAGE_NAME):$(IMAGE_TAG) ls -l /usr/local/bin/
	$(DOCKER) run --rm docker.io/$(IMAGE_NAME):$(IMAGE_TAG) ls -l /etc/systemd/system/

push:
	$(DOCKER) login docker.io
	$(DOCKER) push docker.io/$(IMAGE_NAME):$(IMAGE_TAG)
