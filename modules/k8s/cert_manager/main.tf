terraform {
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
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
  }
}

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.name
  }
}

resource "helm_release" "cert_manager" {
  name       = var.name
  chart      = "cert-manager"
  version    = var.cert_manager_version
  namespace  = var.name
  repository = "https://charts.jetstack.io"

  values = [
    yamlencode({
      fullnameOverride = var.name
      crds = {
        enabled = true
      }
      config = {
        apiVersion       = "controller.config.cert-manager.io/v1alpha1"
        kind             = "ControllerConfiguration"
        enableGatewayAPI = true
      }
      podLabels = {
        "azure.workload.identity/use" = "true"
      }
      serviceAccount = {
        labels = {
          "azure.workload.identity/use" = "true"
        }
        annotations = {
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.namespace
  ]
}
