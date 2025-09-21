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
      sourceNamespaces = [var.destination_namespace]
      sourceRepos      = [var.gitops_repo]
      destinations = [
        {
          server    = var.destination_server
          namespace = var.destination_namespace
        },
      ]
    }
  })
}

resource "kubernetes_namespace_v1" "prod" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.destination_namespace
  }
}

resource "kubernetes_secret_v1" "postgres_database_secret" {
  metadata {
    name      = local.postgres_secret_name
    namespace = var.destination_namespace
  }

  type = "Opaque"

  data = {
    local.postgres_password_key             = var.postgres_admin_password
    local.postgres_replication_password_key = var.postgres_replication_password
    local.hydra_password_key                = var.hydra_database_password
  }
}

module "website_prod" {
  source = "../argo_helm_app"

  project  = local.name
  revision = "HEAD"

  application_name      = local.name
  destination_namespace = var.destination_namespace
  repo                  = var.gitops_repo
  path_to_manifests     = local.path_to_manifests
  sync_policy = {
    automated = {
      prune    = true
      selfHeal = true
    }
  }

  values = {
    # https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values
    valuesObject = {
      fullnameOverride = local.name
    }
  }

  depends_on = [
    kubectl_manifest.argo_appproject,
    kubernetes_namespace_v1.prod,
  ]
}
