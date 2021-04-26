
BALLERINA_IMAGE_TAG := ballerina-test
BALLERINA_CLI_IMAGE := docker run -ti --rm --volume $(CURDIR):/workdir --workdir /workdir $(BALLERINA_IMAGE_TAG)

.PHONY: local-image
local-image:
	docker build . -t $(BALLERINA_IMAGE_TAG)

.PHONY: build
build: local-image
	echo "building developer_service: "
	$(BALLERINA_CLI_IMAGE) build developer_service

.PHONY: run
run: local-image
	$(BALLERINA_CLI_IMAGE) run developer_service