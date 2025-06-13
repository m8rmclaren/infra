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

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.name
  }
}

resource "helm_release" "argo_cd" {
  name       = var.name
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"

  values = [yamlencode({
    crds = {
      install = true
    }

    configs = {
      params = {
        "server.insecure"        = true
        "application.namespaces" = "*"
      }
    }

    controller = {
      replicas = var.application_controller_replicas
    }

    applicationSet = {
      replicas = var.application_set_controller_replicas
    }

    server = {
      autoscaling = {
        enabled  = false
        replicas = var.server_min_replicas
      }
    }

    repoServer = {
      autoscaling = {
        enabled  = false
        replicas = var.repo_server_min_replicas
      }
    }
  })]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}
