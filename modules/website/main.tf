terraform {
  required_version = ">= v1.12.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

resource "kubectl_manifest" "argo_appproject" {
  validate_schema = false

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = local.name
      namespace = var.argocd_namespace
    }
    spec = {
      sourceNamespaces = [local.stage_namespace, local.prod_namespace]
      sourceRepos      = [var.gitops_repo]
      destinations = [
        {
          server    = var.destination_server
          namespace = local.stage_namespace
        },
        {
          server    = var.destination_server
          namespace = local.prod_namespace
        }
      ]
    }
  })
}

