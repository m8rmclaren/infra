module "prod_domain" {
  source = "../domain"

  domain     = var.domain
  ip_address = var.ip_address
  proxied    = false
}

module "prod_www" {
  source = "../domain"

  domain     = var.domain
  subdomain  = "www"
  ip_address = var.ip_address
  proxied    = true
}

resource "kubernetes_namespace_v1" "prod" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = local.prod_namespace
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

module "website_prod" {
  source = "../argo_helm_app"

  project  = local.name
  revision = "HEAD"

  application_name      = "website-prod"
  destination_namespace = "website-prod"
  repo                  = var.gitops_repo
  path_to_manifests     = var.path_to_prod_manifests

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
          "cert-manager.io/cluster-issuer"                   = var.cluster_issuer
          "nginx.ingress.kubernetes.io/from-to-www-redirect" = "true"
        }
        host      = var.domain
        enableTls = true
        additionalTLSHosts = [
          "www.${var.domain}"
        ]
      }
    }
  }

  depends_on = [
    kubectl_manifest.argo_appproject,
    kubernetes_namespace_v1.prod,
    module.prod_domain
  ]
}


