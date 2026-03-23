# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform-based infrastructure-as-code (IaC) project that provisions and manages a Kubernetes cluster on DigitalOcean with supporting services, using a GitOps approach via ArgoCD.

## Common Commands

### Terraform Format & Validate

```bash
# Format check
terraform -chdir=environments/prod/infra fmt -check
terraform -chdir=environments/prod/k8s fmt -check

# Auto-format
terraform -chdir=environments/prod/infra fmt -recursive
terraform -chdir=environments/prod/k8s fmt -recursive

# Validate
terraform -chdir=environments/prod/infra validate
terraform -chdir=environments/prod/k8s validate
```

### Terraform Plan & Apply

```bash
# Init (required after module changes or first run)
terraform -chdir=environments/prod/infra init
terraform -chdir=environments/prod/k8s init

# Plan
terraform -chdir=environments/prod/infra plan
terraform -chdir=environments/prod/k8s plan

# Apply (infra must be applied before k8s)
terraform -chdir=environments/prod/infra apply
terraform -chdir=environments/prod/k8s apply -var="kubeconfig=<kubeconfig_path>"
```

## Architecture

### Two-Layer Terraform Structure

The project is split into two sequentially-dependent layers under `environments/prod/`:

1. **`infra/`** — Provisions DigitalOcean infrastructure: VPC (10.0.4.0/22), reserved IP, SSH keys, and the K8s control plane droplet (Ubuntu 22.04, 2vCPU/4GB, SFO2). Outputs a kubeconfig used by the k8s layer.

2. **`k8s/`** — Deploys all Kubernetes workloads using Kubernetes, Helm, kubectl, GitHub, and Cloudflare providers. Depends on the kubeconfig output from the infra layer. This layer also manages Cloudflare DNS records.

The k8s layer receives the kubeconfig by reading infra state output (automated in CI via `terraform -chdir=environments/prod/infra output -raw kubeconfig`).

### Reusable Modules (`modules/`)

All infrastructure logic lives in reusable modules. The k8s environment wires them together:

| Module | Purpose |
|--------|---------|
| `controlplane` | Self-managed K8s via cloud-init on a DigitalOcean droplet |
| `argocd` | GitOps CD platform (Helm chart), syncs from `m8rmclaren/infra-gitops` repo |
| `argo_helm_app` | Generic wrapper for deploying any Helm app via ArgoCD AppProject |
| `auth` | Ory Kratos (identity) + Ory Hydra (OAuth2/OIDC) with Apple SIWA support |
| `cert_manager` | Let's Encrypt via cert-manager with Cloudflare DNS-01 challenge |
| `database` | PostgreSQL with replication via Helm/ArgoCD |
| `domain` | Cloudflare DNS A record management |
| `external_dns` | Automatic DNS updates from K8s service annotations |
| `gateway` | Kubernetes Gateway API config |
| `ghcr_pull_secret` | GHCR image pull secrets for private container images |
| `health_auto_export_server` | Health metrics auto-export server |
| `istio` | Service mesh |
| `website` | Website deployment via ArgoCD |

### GitOps Pattern

- **App definitions** live in this repo (Terraform manages ArgoCD `Application` resources)
- **App manifests/Helm values** live in `m8rmclaren/infra-gitops` (synced by ArgoCD)
- This means Terraform provisions the ArgoCD `Application` CRD, ArgoCD handles actual K8s deployment

### State Management

- Backend: AWS S3 (`m8rmclaren-terraform-state-infra`, us-west-1) with encryption
- Separate state files for `infra` and `k8s` layers
- Auth: GitHub Actions uses AWS OIDC (`arn:aws:iam::691595548805:role/github_actions_full_admin`)

### CI/CD

- **`plan.yml`**: Runs on PRs — formats, validates, and plans both layers; posts results as sticky PR comments
- **`apply.yml`**: Runs on push to `main` — applies infra first, then k8s. Includes fresh-cluster detection logic that taints resources on first apply (checks namespace count to determine if cluster is new)

### Key Secrets (managed in GitHub Actions environment `prod`)

`DIGITALOCEAN_TOKEN`, `CLOUDFLARE_API_TOKEN`, `GH_PAT`, `EMAIL`, `DOMAIN`, `POSTGRES_ADMIN_PASSWORD`, `POSTGRES_REPLICATION_PASSWORD`, `HYDRA_DATABASE_PASSWORD`, `HYDRA_SYSTEM_SECRET`, `HYDRA_COOKIE_SECRET`, `KRATOS_DATABASE_PASSWORD`, `APPLE_DEVELOPER_TEAM_ID`, `CHAT_PRIMARY_APP_ID`

## Bootstrap

To initialize the S3 state backend (one-time setup):

```bash
aws s3api create-bucket \
    --bucket m8rmclaren-terraform-state-infra \
    --region us-west-1 \
    --create-bucket-configuration LocationConstraint=us-west-1
```

If the bucket name or region is changed, update both `backend.tf` files accordingly.
