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

provider "kubernetes" {
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
  }
}

module "certmanager" {
  source               = "../../../modules/cert_manager"
  name                 = "cert-manager"
  cert_manager_version = "v1.18.0" # Latest as of 6/13/25
}

module "externaldns" {
  source               = "../../../modules/external_dns"
  name                 = "external-dns"
  external_dns_version = "1.16.1" # Latest as of 6/13/25
  cloudflare_api_key   = var.cloudflare_api_key
}
