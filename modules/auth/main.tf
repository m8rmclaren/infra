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
      clusterResourceWhitelist = [
        {
          group = "rbac.authorization.k8s.io"
          kind  = "ClusterRole"
        },
        {
          group = "rbac.authorization.k8s.io"
          kind  = "ClusterRoleBinding"
        },
        {
          group = "apiextensions.k8s.io"
          kind  = "CustomResourceDefinition"
        },
      ]
    }
  })
}

locals {
  auth_hostname = "${var.subdomain}.${var.domain}"
}

module "auth_domain" {
  source = "../domain"

  domain     = var.domain
  subdomain  = var.subdomain
  ip_address = var.ip_address
  proxied    = false

}

resource "kubernetes_namespace_v1" "auth" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.destination_namespace
  }

  depends_on = [module.auth_domain]
}

resource "kubernetes_secret_v1" "config" {
  metadata {
    name      = local.secret_name
    namespace = var.destination_namespace
  }

  type = "Opaque"

  data = {
    (local.hydra_dsn_key) = "postgres://${var.hydra_database_username}:${var.hydra_database_password}@${var.postgres_hostname}:5432/${var.hydra_database_name}"
    secretsSystem         = var.hydra_system_secret
    secretsCookie         = var.hydra_cookie_secret

    (local.kratos_dsn_key) = "postgres://${var.kratos_database_username}:${var.kratos_database_password}@${var.postgres_hostname}:5432/${var.kratos_database_name}"
  }
}

module "auth" {
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
      hostname         = local.auth_hostname
      ingress = {
        enableTls = true
        annotations = {
          "cert-manager.io/cluster-issuer" = var.cluster_issuer
        }
      }
      hydra  = local.hydra
      kratos = local.kratos
    }
  }

  depends_on = [
    kubectl_manifest.argo_appproject,
    kubernetes_namespace_v1.auth,
  ]
}
