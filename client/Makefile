DOCKER=/bin/docker
DOCKER_IMAGE_NAME=acch/tinysync-client
DOCKER_BASE_NAME=ubuntu
DOCKER_BASE_VERSION=latest

default: build

build:
	$(DOCKER) pull $(DOCKER_BASE_NAME):$(DOCKER_BASE_VERSION)
	$(DOCKER) build -t $(DOCKER_IMAGE_NAME) .

push:
	$(DOCKER) login
	$(DOCKER) push $(DOCKER_IMAGE_NAME)

test:
	$(DOCKER) run --rm $(DOCKER_IMAGE_NAME) ls -l /usr/local/bin/
	$(DOCKER) run --rm $(DOCKER_IMAGE_NAME) ls -l /etc/systemd/system/

clean:
	$(DOCKER) images -qf dangling=true | xargs --no-run-if-empty $(DOCKER) rmi
	$(DOCKER) volume ls -qf dangling=true | xargs --no-run-if-empty $(DOCKER) volume rm
