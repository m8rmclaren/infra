terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

resource "kubectl_manifest" "argo_application" {
  validate_schema = false

  yaml_body = yamlencode({
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
  })
}
