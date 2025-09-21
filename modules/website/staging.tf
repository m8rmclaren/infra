module "staging_domain" {
  source = "../domain"

  domain     = var.domain
  subdomain  = local.stage_subdomain
  ip_address = var.ip_address
  proxied    = false
}

resource "kubernetes_namespace_v1" "staging" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = local.stage_namespace
  }
}

module "ghcr_pull_secret" {
  source = "../ghcr_pull_secret"

  secret_name = local.ghcr_pull_secret
  namespace   = kubernetes_namespace_v1.staging.metadata[0].name

  github_email = var.github_email
  github_token = var.github_token


  depends_on = [kubernetes_namespace_v1.staging]
}

module "website_staging" {
  source = "../argo_helm_app"

  project  = local.name
  revision = "HEAD"

  application_name      = "website-staging"
  destination_namespace = "website-staging"
  repo                  = var.gitops_repo
  path_to_manifests     = local.path_to_stage_manifests

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
      imagePullSecrets = [{ name = local.ghcr_pull_secret }]
      ingress = {
        enabled   = true
        className = "nginx"
        annotations = {
          "cert-manager.io/cluster-issuer" = var.cluster_issuer
        }
        host      = "${local.stage_subdomain}.${var.domain}"
        enableTls = true
      }
    }
  }

  depends_on = [
    kubectl_manifest.argo_appproject,
    kubernetes_namespace_v1.staging,
    module.staging_domain
  ]
}

