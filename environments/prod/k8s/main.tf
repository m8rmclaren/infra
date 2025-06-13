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
    bucket       = "m8rmclaren-terraform-state-infra"
    key          = "prod/terraform.tfstate"
    region       = "us-west-1"
  }
}

provider "kubernetes" {
  config_path = data.terraform_remote_state.infra.outputs.kubeconfig
}

provider "helm" {
  kubernetes = {
  config_path = data.terraform_remote_state.infra.outputs.kubeconfig
  }
}

