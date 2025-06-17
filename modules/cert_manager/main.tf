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
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

locals {
  name                           = "cert-manager"
  cloudflare_api_key_secret_name = "cloudflare-api-key"
  cloudflare_api_key_secret_key  = "apiKey"
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = local.name
  }
}

resource "helm_release" "cert_manager" {
  name       = local.name
  chart      = "cert-manager"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"

  values = [
    yamlencode({
      fullnameOverride = local.name

      crds = {
        enabled = true
      }
      # config = {
      #   apiVersion       = "controller.config.cert-manager.io/v1alpha1"
      #   kind             = "ControllerConfiguration"
      #   enableGatewayAPI = true
      # }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.cert_manager
  ]
}

resource "kubernetes_secret_v1" "cloudflare_api_key" {
  metadata {
    name      = local.cloudflare_api_key_secret_name
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
  }

  type = "Opaque"

  data = {
    (local.cloudflare_api_key_secret_key) = var.cloudflare_api_key
  }

  depends_on = [kubernetes_namespace_v1.cert_manager, helm_release.cert_manager]
}

resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  validate_schema = false

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cluster_issuer
    }
    spec = {
      acme = {
        server = var.acme_server
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = kubernetes_secret_v1.cloudflare_api_key.metadata[0].name
                  key  = local.cloudflare_api_key_secret_key
                }
              }
            }
          }
        ]
      }
    }
  })

  depends_on = [kubernetes_secret_v1.cloudflare_api_key]
}

