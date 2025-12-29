# rshutt-exercise

## Purpose

The content herein exists to meet the requirements for Randall Shutt's Interview Exercise with the XYZ Corporation.

This repository is intentionally scoped to demonstrate patterns, not to represent a complete production platform.

## Problem Framing

### Current State

The XYZ Corporation currently has:

1. Slow environment provisioning
1. Unique "snowflake" environments
1. Risky deployments
1. No confidence in rollback capabilities
1. A poor developer experience

### Desired Outcomes

This work is to provide an example of what good could look like regarding the solution of the aforementioned issues.

Specifically, we seek to demonstrate

1. Fast, repeatable environment creation
1. Immutable infrastructure, defined in IaC
1. Low-risk deployments
1. A clear rollback strategy
1. An observable and testable system

### Non-Goals

This exercise explicitly does not attempt to create or implement the following.

1. A model of a full enterprise networking or security posture.
1. A complete GitOps platform.
1. Optimizations for long-lived production efficiencies (e.g. cost, resiliency)

## Architecture

In order to facilitate these solutions, we will need to first define an architecture which uses widely adoptyed, production-proven approaches to solving the stated problems.

### Cloud Provider

AWS will be the cloud provider of choice.

1. AWS is basically ubiquitous in the public cloud space.
1. EKS is familiar to most audiences.
1. I have hands-on experience operating Kubernetes via EKS, OpenShift, Rancher, and kubeadm-based deployments. Within AWS, EKS represents the quickest path to a supportable, production-ready Kubernetes platform.
1. Terraform support is mature.

### Container Orchestration Engine

EKS is clearly the best choice here

1. EKS deployment, configuration, and operations are well-known skills in most organizations.
1. Provides a clear demarcation between the infra component builds, and the CI/CD workflow to deploy the app.
1. Feels less "demo-only" than standing up a `kind` instance.

### IaC platform

Terraform is my preferred choice, though this is not always the case with customers

1. Excellent support for AWS and EKS
1. Arguably, the platform agnostic industry standard for IaC.
1. Most DevOps-enabled engineers, both software and infra, are familiar with Terraform and HCL at this point.

### Application Language/Architecture

For this engagement, I like the simplicity of Python.

1. FastAPI makes writing http handlers quite simple.
1. Testing is also simplified using TestClient
1. Python is another technology that a majority of DevOps-enabled engineers will have had exposure to.

### CI/CD Platform Choice

For most non-GitOps use cases, GitHub Actions is my preferred choice.

1. GitHub Actions is broadly available and familiar.
1. Integration with pull requests enables fast feedback.
1. Fully capable of executing the both infrastructure and application builds and deployments

## Local Development

This repository uses `pre-commit` to provide fast local feedback for common formatting and validation issues.

To enable:

```bash
pip install pre-commit
pre-commit install
```

## The automater_ws Python application

### High level

This application is quite basic as it is an example application that outputs the requested output when the `/` URI is accessed.

- Runs in python3.13 or newer.
- Using PEP 517 / PEP 621 with setuptools + pip.
- Poetry was not chosen due to it wanting to "own" the workflows related to build.
- Uses pyproject.toml to define the various confiuration variables required for the packaging.
- Unit testing enabled via pytest.
- Integration testing should and will be done in the repo's ci/cd in orchestration with the infrastructure.
- Uses FastAPI since that seems quite straightforward and also has the easy access to TestClient.
- Uses a routes/ subdir approach to populate the API endpoints.
- Adds 2 additional routes to make kubernetes readiness and liveness checks seamless.
- Leverages the top level Makefile to create, test, and run the application in a container.
- Requires Docker Desktop (or equivallent containervisor)
- Requires VERSION come from either the git repository's tag, or overrideen with the VERSION variable when running `make`

## The AWS / Terraform tooling

### AWS Infrastructure (Multi-Account, Guardrail-First)

The `infra/` directory contains all AWS infrastructure managed via Terraform.
It follows a single-repo, multi-account model with explicit permssions and roles.

The structure and ordering are intentional and optimized for:

- security and auditability
- cost control
- clarity of work

#### Account model

This repo assumes an AWS Organizations layout with distinct responsibilities:

- Management account
  - AWS Organizations
  - Service Control Policies (SCPs)
  - Cost guardrails (budgets, anomaly detection)

- Log Archive / Security account
  - Centralized CloudTrail (organization trail)
  - Immutable-ish log storage (S3 + KMS)
  - Audit isolation from workload accounts

Workload accounts (dev/prod) are intentionally excluded here and live under
`infra/aws/workloads/` when needed.

---

#### Directory layout & ordering

```text
infra/aws/
  org/
    00-organizations/
  security/
    10-log-archive/
  cost/
    20-cost-guardrails/
  modules/
```
