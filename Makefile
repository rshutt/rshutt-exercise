SHELL := /bin/bash

APP_NAME        ?= automater-ws
AWS_REGION      ?= us-east-1
AWS_ACCOUNT_ID  ?= 000000000000
ECR_REPO        ?= $(APP_NAME)
ECR_REGISTRY    := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
IMAGE           := $(APP_NAME)
VENV            := .venv
PIP             := $(VENV)/bin/pip
PYTHON          := $(VENV)/bin/python

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
	@echo "  make venv         Build local test venv"
	@echo "  make unit_test    Run local unit tests"
	@echo "  make clean        Cleanup venv"
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

.PHONY: venv
venv:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip

.PHONY: unit_test
unit_test: venv
	$(PIP) install -e .[dev]
	$(VENV)/bin/pytest

.PHONY: clean
clean:
	rm -rf $(VENV)
	rm -rf ./src/*.egg-info

.PHONY: all
all: build push
