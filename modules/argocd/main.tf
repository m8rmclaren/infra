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
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

locals {
  name = "argo-cd"
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = local.name
  }
}

resource "helm_release" "argo_cd" {
  name       = local.name
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"

  values = [yamlencode({
    fullnameOverride = local.name

    crds = {
      install = true
    }

    configs = {
      params = {
        "server.insecure"        = true
        "application.namespaces" = "*"
      }
      secret = {
        # htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/' | pbcopy
        argocdServerAdminPassword = "$2a$10$IHGMIO64MlfQb6HdSZa4COFh0kHDpjSnKaWW1gcJRL8.v2f5mK30W"
      }
    }

    controller = {
      replicas = var.application_controller_replicas
    }

    applicationSet = {
      replicas = var.application_set_controller_replicas
    }

    server = {
      autoscaling = {
        enabled  = false
        replicas = var.server_min_replicas
      }
      # Conditionally add the ingress block only if gateway_name and gateway_namespace are empty
      ingress = (
        var.gateway_name == "" && var.gateway_namespace == "" ?
        {
          enabled = true
          annotations = {
            "cert-manager.io/cluster-issuer" = var.cluster_issuer
          }
          controller       = "generic"
          ingressClassName = "nginx"
          hostname         = var.hostname
          tls              = true
        } :
        null
      )
    }

    repoServer = {
      autoscaling = {
        enabled  = false
        replicas = var.repo_server_min_replicas
      }
    }
  })]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}

resource "kubernetes_manifest" "argocd_http_route" {
  count = (
    var.gateway_name != "" &&
    var.gateway_namespace != ""
  ) ? 1 : 0

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = local.name
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    }
    spec = {
      parentRefs = [
        {
          name      = var.gateway_name
          namespace = var.gateway_namespace
        }
      ]
      hostnames = [
        var.hostname
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = "${local.name}-server"
              port = 80
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    helm_release.argo_cd
  ]
}
