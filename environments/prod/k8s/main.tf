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
  }
}

locals {
  cluster_issuer_name = "letsencrypt"
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

module "certmanager" {
  source             = "../../../modules/cert_manager"
  chart_version      = "1.18.0"
  cluster_issuer     = local.cluster_issuer_name
  cloudflare_api_key = var.cloudflare_api_key
  # acme_server        = "https://acme-v02.api.letsencrypt.org/directory"
  acme_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
  domain      = var.domain
  email       = var.email
}

module "argocd" {
  source                              = "../../../modules/argocd"
  chart_version                       = "8.0.17" # Latest as of 6/13/25
  application_controller_replicas     = 1
  application_set_controller_replicas = 1
  server_min_replicas                 = 1
  repo_server_min_replicas            = 1
  hostname                            = "argocd.${var.domain}"
  cluster_issuer                      = local.cluster_issuer_name
  github_org                          = "m8rmclaren"
  gitops_repository_name              = "infra-gitops"

  depends_on = [module.certmanager]
}
