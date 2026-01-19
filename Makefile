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
TF              ?= terraform
TF_AUTO_APPROVE ?= false
AWS_PROFILE     ?= org-admin

TF_APPLY_FLAGS :=
ifeq ($(TF_AUTO_APPROVE),true)
  TF_APPLY_FLAGS += -auto-approve
endif


export AWS_PROFILE

# Version to bake into setuptools_scm (Docker build-arg)
# Prefer git tag; fall back to short SHA; then "dev"
VERSION         ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)

# Local tag
TAG             ?= $(VERSION)

# ECR tag
ECR_IMAGE       := $(ECR_REGISTRY)/$(ECR_REPO):$(TAG)o

# ==== helpers ====
define tf_run
	cd $(1) && \
	$(TF) init && \
	$(TF) $(2) $(TF_APPLY_FLAGS)
endef

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

.PHONY: tf-bootstrap
tf-bootstrap:
	@echo "==> Bootstrapping infrastructure <=="
	$(MAKE) tf-state
	$(MAKE) tf-org
	$(MAKE) tf-identity-center
	$(MAKE) tf-log-archive
	$(MAKE) tf-vpc
	$(MAKE) tf-cost
	$(MAKE) tf-guardduty-admin
	$(MAKE) tf-guardduty

.PHONY:  tf-state
tf-state:
	@echo "==> Applying initial state bucket <=="
	$(call tf_run,infra/aws/bootstrap/00-tf-state,apply)

.PHONY:  tf-org
tf-org:
	@echo "==> Creating base suborganzations <=="
	$(call tf_run,infra/aws/bootstrap/01-org,apply)

.PHONY: tf-identity-center
tf-identity-center:
	@echo "==> Configuring Identity Center (see notes to enable) <=="
	$(call tf_run,infra/aws/boostrap/05-identity-center,apply)

.PHONY: tf-log-archive
tf-log-archive:
	@echo "==> Configuring log archive s3 bucket <=="
	$(call tf_run,infra/aws/bootstrap/10-log-archive,apply)

.PHONY: tf-vpc
tf-vpc:
	@echo "==> Configuring VPCs <=="
	$(call tf_run,infra/aws/bootstrap/15-vpc,apply)

.PHONY: tf-cost
tf-cost:
	@echo "==> Configuring cost management <=="
	$(call tf_run,infra/aws/bootstrap/20-cost,apply)

.PHONY: tf-guardduty-admin
tf-guardduty-admin:
	@echo "==> Configuring guardduty perms  <=="
	$(call tf_run,infra/aws/bootstrap/24-guardduty-admin)

.PHONY: tf-guardduty
tf-guardduty:
	@echo "==> Configure Guard Duty <=="
	$(call tf_run,infra/aws/bootstrap/25-guardduty,apply)

.PHONY: tf-plan-state tf-plan-org tf-plan-iam tf-plan-identity-center tf-plan-log-archive tf-plan-vpc tf-plan-cost tf-plan-guardduty-admin tf-plan-guardduty

tf-plan-state:
	@echo "==> Planning initial state bucket <=="
	$(call tf_run,infra/aws/bootstrap/00-state,plan)

tf-plan-org:
	@echo "==> Planning base suborganzations <=="
	$(call tf_run,infra/aws/bootstrap/01-org,plan)

tf-plan-iam:
	@echo "==> Planning IAM <=="
	$(call tf_run,infra/aws/bootstrap/03-bootstrap-iam,plan)

tf-plan-identity-center:
	@echo "==> Planning Identity Center (see notes to enable) <=="
	$(call tf_run,infra/aws/boostrap/05-identity-center,plan)

tf-plan-log-archive:
	@echo "==> Planning log archive s3 bucket <=="
	$(call tf_run,infra/aws/bootstrap/10-log-archive,plan)

tf-plan-vpc:
	@echo "==> Planning VPCs <=="
	$(call tf_run,infra/aws/bootstrap/15-vpc,plan)

tf-plan-cost:
	@echo "==> Planning cost management <=="
	$(call tf_run,infra/aws/bootstrap/20-cost,plan)

tf-plan-guardduty-admin:
	@echo "==> Planning guardduty perms  <=="
	$(call tf_run,infra/aws/bootstrap/24-guardduty-admin)

tf-plan-guardduty:
	@echo "==> Configure Guard Duty <=="
	$(call tf_run,infra/aws/bootstrap/25-guardduty,plan)

# ---- meta ----

.PHONY: tf-infra-all
tf-infra-all: tf-state tf-org tf-identity-center tf-log-archive tf-vpc tf-cost tf-guardduty-admin tf-guardduty

.PHONY: all
all: build push
