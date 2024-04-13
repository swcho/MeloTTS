
ifndef NAME
$(error NAME is not set)
endif
ifndef PORT
$(error PORT is not set)
endif

IMAGE_NAME=$(NAME)
TAG := $$(git describe --always --dirty)

ARGS=--name=$(NAME) -p $(PORT):$(PORT) $(USER_ARGS) $(IMAGE_NAME)
BUILD_ARGS :=$(BUILD_ARGS) -t

docker.login:
	docker login $(REGISTRY_HOST)

docker.build:
	docker build $(BUILD_ARGS) $(IMAGE_NAME) .

docker.build.force:
	docker build --no-cache $(BUILD_ARGS) $(IMAGE_NAME) .

# https://stackoverflow.com/a/10557860/5742483
docker.push:
	@status=$$(git status --porcelain); \
	if test "x$${status}" = x; then \
		docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(TAG); \
		docker push $(IMAGE_NAME):$(TAG); \
		echo Image pushed: $(IMAGE_NAME):$(TAG); \
	else \
		echo Unable to push: Working directory is dirty >&2; \
	fi

docker.rm:
	docker rm -f $(NAME)

docker.stop:
	-docker stop $(NAME)

docker.run: docker.stop
	docker run --rm -d $(ARGS)
	docker logs --follow $(NAME)

docker.test: docker.build
	docker run -it --rm $(ARGS) bash

docker.test_root:
	docker run -it --rm --user=root $(ARGS) bash

docker.exec:
	docker exec -it $(NAME) bash
