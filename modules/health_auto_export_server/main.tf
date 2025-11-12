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
      sourceNamespaces = [local.namespace]
      sourceRepos      = [var.gitops_repo]
      destinations = [
        {
          server    = var.destination_server
          namespace = local.namespace
        },
      ]
    }
  })
}

module "domain" {
  source = "../domain"

  domain     = var.domain
  subdomain  = var.subdomain
  ip_address = var.ip_address
  proxied    = false
}

resource "kubernetes_namespace_v1" "prod" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = local.namespace
  }
}

module "prod_ghcr_pull_secret" {
  source = "../ghcr_pull_secret"

  secret_name = local.ghcr_pull_secret
  namespace   = kubernetes_namespace_v1.prod.metadata[0].name

  github_email = var.github_email
  github_token = var.github_token


  depends_on = [kubernetes_namespace_v1.prod]
}

module "health_auto_export_server" {
  source = "../argo_helm_app"

  project  = local.name
  revision = "HEAD"

  application_name      = "health-auto-export-server"
  destination_namespace = local.namespace
  repo                  = var.gitops_repo
  path_to_manifests     = local.path_to_prod_manifests

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
      server = {
        imagePullSecrets = [{ name = local.ghcr_pull_secret }]
      }
      ingress = {
        enabled   = true
        className = "nginx"
        annotations = {
          "cert-manager.io/cluster-issuer"                   = var.cluster_issuer
          "nginx.ingress.kubernetes.io/from-to-www-redirect" = "true"
        }
        host      = "${var.subdomain}.${var.domain}"
        enableTls = true
      }
    }
  }

  depends_on = [
    kubectl_manifest.argo_appproject,
    kubernetes_namespace_v1.prod,
    module.domain
  ]
}


