terraform {
  required_version = ">= v1.12.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "m8rmclaren-terraform-state-infra"
    key    = "prod/terraform.tfstate"
    region = "us-west-1"
  }
}

locals {
  cluster_issuer_name = "letsencrypt"
  public_ip           = data.terraform_remote_state.infra.outputs.public_ip
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
  }
}

provider "kubectl" {
  config_path = var.kubeconfig
}

provider "github" {
  token = var.github_pat
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "certmanager" {
  source = "../../../modules/cert_manager"

  chart_version      = "1.18.0"
  cluster_issuer     = local.cluster_issuer_name
  cloudflare_api_key = var.cloudflare_api_token
  acme_server        = "https://acme-v02.api.letsencrypt.org/directory"
  # acme_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
  domain = var.domain
  email  = var.email
}

locals {
  argocd_subdomain = "argocd"
}

module "argocdsubdomain" {
  source = "../../../modules/domain"

  domain     = var.domain
  subdomain  = local.argocd_subdomain
  ip_address = local.public_ip
  proxied    = true
}

module "argocd" {
  source = "../../../modules/argocd"

  chart_version                       = "8.0.17" # Latest as of 6/13/25
  application_controller_replicas     = 1
  application_set_controller_replicas = 1
  server_min_replicas                 = 1
  repo_server_min_replicas            = 1
  hostname                            = "argocd.${var.domain}"
  cluster_issuer                      = local.cluster_issuer_name
  github_org                          = "m8rmclaren"
  gitops_repository_name              = "infra-gitops"

  depends_on = [module.certmanager, module.argocdsubdomain]
}

module "database" {
  source = "../../../modules/database"

  argocd_namespace = module.argocd.argocd_namespace
  gitops_repo      = module.argocd.repo_name

  destination_namespace = "database"

  postgres_admin_password       = var.postgres_admin_password
  postgres_replication_password = var.postgres_replication_password

  hydra_database_name     = "hydra_db"
  hydra_database_username = "hydra"
  hydra_database_password = var.hydra_database_password
}

module "website" {
  source = "../../../modules/website"

  domain     = var.domain
  ip_address = local.public_ip

  cluster_issuer = local.cluster_issuer_name

  github_email = var.github_email
  github_token = var.github_pat

  argocd_namespace = module.argocd.argocd_namespace
  gitops_repo      = module.argocd.repo_name

  depends_on = [module.argocd]
}
