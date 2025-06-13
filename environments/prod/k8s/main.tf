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


provider "kubernetes" {
  config_path = module.controlplane.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path = module.controlplane.kubeconfig
  }
}

module "cert_manager" {
  source               = "../../../modules/k8s/cert_manager"
  name                 = "cert-manager"
  cert_manager_version = "v1.18.0"

  depends_on = [module.controlplane]
}
