# Terraform AWS EKS Platform

This project provides a cloud infrastructure on AWS using Terraform, including a fully managed Kubernetes cluster (EKS) and a CI/CD pipeline with GitHub Actions.

---

## Overview

The goal of this project is to deploy a scalable and secure AWS infrastructure using Infrastructure as Code (IaC).

It includes:

- VPC networking setup
- Amazon EKS (Kubernetes) cluster
- Managed node groups
- IAM roles and OIDC authentication
- CI/CD pipelines using GitHub Actions

---

## Architecture

- Terraform modules for infrastructure components
- Separate environments: **dev / staging / production**
- Git-based workflow for deployments
- Automated CI/CD with GitHub Actions

---

## AWS Components

- Amazon VPC (public & private subnets)
- Amazon EKS cluster
- EC2 node groups with autoscaling
- IAM roles for secure access

---

## CI/CD Pipeline

The project uses GitHub Actions with OIDC authentication to securely deploy infrastructure without static AWS credentials.

Environments:

- **dev** → fast testing environment
- **staging** → pre-production validation
- **production** → protected environment with manual approval

---

## Branch Strategy

- `develop` → dev environment
- `staging` → staging environment
- `main` → production environment

---

## Terraform Structure

```
.
├── backend.tf
├── envs
│   ├── dev
│   │   └── dev.tfvars
│   ├── prod
│   │   └── prod.tfvars
│   └── staging
│       └── staging.tfvars
├── main.tf
├── modules
│   ├── eks
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── node-group
│   │   ├── main.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── providers.tf
├── variables.tf
└── versions.tf
```

---

## Security

- AWS credentials managed via GitHub OIDC
- No static access keys used
- Production deployments require manual approval

---

## Deployment

Each push to a branch triggers the corresponding pipeline:

- `develop` → deploy to dev
- `staging` → deploy to staging
- `main` → deploy to production (manual approval required)

---

## Status

This project is a learning and portfolio project demonstrating modern DevOps practices with AWS and Terraform.

---

## Tech Stack

- Terraform
- AWS (EKS, VPC, IAM, EC2)
- GitHub Actions
