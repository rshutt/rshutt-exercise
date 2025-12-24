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

1. Since immutable infrastructure is part of the solution, using kind or k3s does not allow us to demonstrate this nor does using ECS.
1. Will show a clear demarcation between the infra component builds and the CI/CD workflow to deploy the app.
1. Feels less "demo-only"

### IaC platform

Terraform is my preferred choice, though similar could be done using CloudFormation if there is pushback.

1. Excellent support for AWS and EKS
1. Arguably, the platform agnostic industry standard for IaC.
1. A majority of DevOps-enabled engineers, both software and infra, are familiar with Terraform and HCL at this point.

### Application Language/Architecture

For this exercise, I like the simplicity of Python.

1. FastAPI makes writing http handlers quite simple.
1. Testing is also simplified using TestClient
1. Python is another technology that a majority of DevOps-enabled engineers will have had exposure to.

### CI/CD Platform Choice

For most non-GitOps use cases, GitHub Actions is my preferred choice.

1. GitHub Actions is broadly available and familiar, lowering the barrier to entry for reviewers and future contributors.
1. Tight integration with pull requests enables fast feedback loops (tests, linting, and Terraform validation) and improves developer experience.
1. It provides a simple path to building and publishing immutable container images, as well as deploying to EKS in a repeatable, automated way.
1. While I like GitOps tooling (e.g., ArgoCD) in long-lived platforms, this exercise focuses on demonstrating repeatability and safe delivery without introducing additional control-plane components.

## Local Development

This repository uses `pre-commit` to provide fast local feedback for common formatting and validation issues.

To enable:

```bash
pip install pre-commit
pre-commit install
```
