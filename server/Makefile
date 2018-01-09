DOCKER=/bin/docker
DOCKER_IMAGE_NAME=acch/tinysync
DOCKER_BASE_NAME=alpine
DOCKER_BASE_VERSION=3.7

default: build

build:
	$(DOCKER) pull $(DOCKER_BASE_NAME):$(DOCKER_BASE_VERSION)
	$(DOCKER) build -t $(DOCKER_IMAGE_NAME) .

push:
	$(DOCKER) login
	$(DOCKER) push $(DOCKER_IMAGE_NAME)

test:
	$(DOCKER) run --rm --env AUTHORIZED_KEYS="test" $(DOCKER_IMAGE_NAME) -t

clean:
	$(DOCKER) images -qf dangling=true | xargs --no-run-if-empty $(DOCKER) rmi
	$(DOCKER) volume ls -qf dangling=true | xargs --no-run-if-empty $(DOCKER) volume rm
