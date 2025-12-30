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
	@echo "==> Bootstrapping Terraform state (S3 + lockfile)"
	$(call tf_run,infra/aws/bootstrap/00-tf-state,apply)

# ---- org / guardrails ----

.PHONY: tf-org
tf-org:
	@echo "==> Applying AWS Organizations + SCPs"
	$(call tf_run,infra/aws/org/00-org,apply)

.PHONY: tf-bootstrap-iam
tf-bootstrap-iam: tf-org
	@echo "==> Applying AWS Bootstrap IAM"
	$(call tf_run,infra/aws/org/01-bootstrap-iam,apply)

.PHONY: tf-identity-center
tf-identity-center: tf-org
	@echo "==> Applying AWS Identity Center"
	$(call tf_run,infra/aws/org/05-identity-center,apply)

.PHONY: tf-log-archive
tf-log-archive: tf-org tf-bootstrap-iam
	@echo "==> Applying Log Archive / Org CloudTrail"
	$(call tf_run,infra/aws/security/10-log-archive,apply)

.PHONY: tf-cost
tf-cost: tf-org tf-boostrap-iam
	@echo "==> Applying Cost Guardrails"
	$(call tf_run,infra/aws/cost/20-cost,apply)

.PHONY: tf-guardduty-admin
tf-guardduty-admin: tf-org tf-boostrap-iam
	@echo "==> Applying Guardduty Admin"
	$(call tf_run,infra/aws/org/20-guardduty-admin,apply)

.PHONY: tf-guardduty
tf-guardduty: tf-org tf-boostrap-iam
	@echo "==> Applying Guardduty"
	$(call tf_run,infra/aws/org/25-guardduty-admin,apply)
# ---- plan targets (safe) ----

.PHONY: tf-plan-org tf-plan-log tf-plan-cost tf-plan-bootstrap tf-plan-guardduty-admin tf-plan-guardduty

tf-plan-org:
	$(call tf_run,infra/aws/org/00-org,plan)

tf-plan-bootstrap-iam:
	$(call tf_run,infra/aws/org/01-bootstrap-iam,plan)

tf-plan-identity-center:
	$(call tf_run,infra/aws/org/05-identity-center,plan)

tf-plan-log:
	$(call tf_run,infra/aws/security/10-log-archive,plan)

tf-plan-cost:
	$(call tf_run,infra/aws/cost/20-cost,plan)

tf-plan-bootstrap:
	$(call tf_run,infra/aws/bootstrap/00-tf-state,plan)

tf-plan-guardduty-admin:
	$(call tf_run,infra/aws/org/20-guardduty-admin,plan)

tf-plan-guardduty:
	export AWS_PROFILE="security-sso"
	$(call tf_run,infra/aws/org/25-guardduty,plan)

# ---- meta ----

.PHONY: tf-all
tf-all: tf-bootstrap tf-org tf-identity-center tf-bootstrap-iam tf-log-archive tf-cost tf-guardduty-admin  tf-guardduty

.PHONY: all
all: build push
