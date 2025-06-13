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

locals {
  cloudflare_api_key_secret_name = "cloudflare-api-key"
  cloudflare_api_key_secret_key  = "apiKey"
}

resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.name
  }
}

resource "kubernetes_secret_v1" "cloudflare_api_key" {
  metadata {
    name      = local.cloudflare_api_key_secret_name
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
  }

  type = "Opaque"

  data = {
    (local.cloudflare_api_key_secret_key) = var.cloudflare_api_key
  }
}

resource "helm_release" "external_dns" {
  name       = var.name
  chart      = "external-dns"
  version    = var.external_dns_version
  namespace  = kubernetes_namespace_v1.external_dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns"

  values = [
    yamlencode({
      fullnameOverride = var.name

      env = [
        {
          name = "CF_API_TOKEN"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret_v1.cloudflare_api_key.metadata[0].name
              key  = local.cloudflare_api_key_secret_key
            }
          }
        }
      ]

      provider = {
        name = "cloudflare"
      }

      policy = "sync"

      extraArgs = [
        "--source=gateway-httproute"
      ]
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.external_dns,
    kubernetes_secret_v1.cloudflare_api_key,
  ]
}

