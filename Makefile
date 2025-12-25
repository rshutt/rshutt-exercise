SHELL := /bin/bash

APP_NAME        ?= automater-ws
AWS_REGION      ?= us-east-1
AWS_ACCOUNT_ID  ?= 000000000000
ECR_REPO        ?= $(APP_NAME)
ECR_REGISTRY    := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE           := $(APP_NAME)

# Version to bake into setuptools_scm (Docker build-arg)
# Prefer git tag; fall back to short SHA; then "dev"
VERSION         ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)

# Local tag
TAG             ?= $(VERSION)

# ECR tag
ECR_IMAGE       := $(ECR_REGISTRY)/$(ECR_REPO):$(TAG)

.PHONY: help
help:
	@echo "Targets:"
	@echo "  make build        Build local image ($(IMAGE):$(TAG))"
	@echo "  make run          Run local image on :8000"
	@echo "  make ecr-login    Login Docker to ECR"
	@echo "  make tag-ecr      Tag local image for ECR ($(ECR_IMAGE))"
	@echo "  make push         Push image to ECR"
	@echo "  make all          build + tag-ecr + push"

.PHONY: build
build:
	echo ${VERSION}
	docker build -t $(IMAGE):$(TAG) --build-arg VERSION=$(VERSION) .

.PHONY: run
run:
	docker run --rm -p 8000:8000 $(IMAGE):$(TAG)

.PHONY: ecr-login
ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REGISTRY)

.PHONY: tag-ecr
tag-ecr:
	docker tag $(IMAGE):$(TAG) $(ECR_IMAGE)

.PHONY: push
push: ecr-login tag-ecr
	docker push $(ECR_IMAGE)

.PHONY: all
all: build push
