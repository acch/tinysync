DOCKER     := /bin/podman
IMAGE_NAME := acch/tinysync
IMAGE_TAG  := latest

BUILDFLAGS := --no-cache --pull

default: build test

build:
	$(DOCKER) build $(BUILDFLAGS) -t $(IMAGE_NAME):$(IMAGE_TAG) .

test:
	$(DOCKER) run --rm --env AUTHORIZED_KEYS="test" $(IMAGE_NAME):$(IMAGE_TAG) -t

push:
	$(DOCKER) login
	$(DOCKER) push $(IMAGE_NAME):$(IMAGE_TAG)
