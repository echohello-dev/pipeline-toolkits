PLATFORM ?= linux/amd64
VERSION ?= $(shell git rev-parse --short HEAD)

login-github:
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is not set)
endif
	docker login ghcr.io -u default -p $(GITHUB_TOKEN)

build:
ifndef NAME
	$(error NAME is not set)
endif
	docker build \
		-t ghcr.io/echohello-dev/pipeline-toolkits/$(NAME):latest \
		-t ghcr.io/echohello-dev/pipeline-toolkits/$(NAME):$(VERSION) \
		containers/$(NAME)

publish: login-github
ifndef NAME
	$(error NAME is not set)
endif
	docker build \
		--platform $(PLATFORM) \
		-t ghcr.io/echohello-dev/pipeline-toolkits/$(NAME):latest \
		-t ghcr.io/echohello-dev/pipeline-toolkits/$(NAME):$(VERSION) \
		--push \
		containers/$(NAME)