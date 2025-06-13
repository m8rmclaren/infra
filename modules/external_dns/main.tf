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

locals {
  cloudflare-api-key-secret-name = "cloudflare-api-key"
}

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.name
  }
}

resource "kubernetes_secret_v1" "cloudflare-api-key" {
  metadata {
    name      = local.cloudflare-api-key-secret-name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  type = "Opaque"

  data = {
    username = "admin"
  }
}
