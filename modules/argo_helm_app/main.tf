terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
  }
}

resource "kubernetes_manifest" "argo_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name        = var.application_name
      namespace   = var.destination_namespace
      annotations = var.application_annotations
    }
    spec = {
      project = var.project
      source = {
        repoURL        = var.repo
        path           = var.path_to_manifests
        targetRevision = var.revision

        # Optional Helm config
        helm = var.values
      }
      destination = {
        server    = var.destination_server
        namespace = var.destination_namespace
      }
      syncPolicy = var.sync_policy
    }
  }
}
