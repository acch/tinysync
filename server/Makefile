DOCKER     := /bin/podman
IMAGE_NAME := acch/tinysync
IMAGE_TAG  := latest

BUILDFLAGS := --no-cache --pull

default: build test

lint:
	$(DOCKER) run --rm -i hadolint/hadolint < Dockerfile

build:
	$(DOCKER) build $(BUILDFLAGS) -t docker.io/$(IMAGE_NAME):$(IMAGE_TAG) .

test:
	$(DOCKER) run --rm --env AUTHORIZED_KEYS="test" docker.io/$(IMAGE_NAME):$(IMAGE_TAG) -t

push:
	$(DOCKER) login docker.io
	$(DOCKER) push docker.io/$(IMAGE_NAME):$(IMAGE_TAG)
