DOCKER     := /bin/docker
IMAGE_NAME := acch/tinysync
IMAGE_TAG  := client-test

BUILDFLAGS := --no-cache --pull

default: build test

build:
	$(DOCKER) build $(BUILDFLAGS) -t $(IMAGE_NAME):$(IMAGE_TAG) .

test:
	$(DOCKER) run --rm $(IMAGE_NAME):$(IMAGE_TAG) ls -l /usr/local/bin/
	$(DOCKER) run --rm $(IMAGE_NAME):$(IMAGE_TAG) ls -l /etc/systemd/system/

push:
	$(DOCKER) login
	$(DOCKER) push $(IMAGE_NAME):$(IMAGE_TAG)
