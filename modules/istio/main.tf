# Example usage
# module "istio" {
#   source        = "../../../modules/istio"
#   chart_version = "1.26.1" # Latest as of 6/13/25
#   replicas      = 1
# }

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

# Download the K8s Gateway API multi-object CRD file
data "http" "gateway_api_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_version}/standard-install.yaml"
}

data "kubectl_file_documents" "gateway_api_crds" {
  content = data.http.gateway_api_crds.response_body

  lifecycle {
    precondition {
      condition     = 200 == data.http.gateway_api_crds.status_code
      error_message = "Status code invalid"
    }
  }
}

# Individually install each manifest
resource "kubectl_manifest" "gateway_api_crds" {
  for_each  = data.kubectl_file_documents.gateway_api_crds.manifests
  yaml_body = each.value
}

resource "kubernetes_namespace_v1" "istio" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = "istio-system"
  }

  depends_on = [kubectl_manifest.gateway_api_crds]
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  chart      = "base"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.istio.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"

  values = [
    yamlencode({
      fullnameOverride = "istio-base"
      defaultRevision  = "default"
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.istio
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  chart      = "istiod"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.istio.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"

  values = [
    yamlencode({
      fullnameOverride = "istiod"
      profile          = "ambient"
      replicaCount     = var.replicas
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
    })
  ]

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "cni" {
  name       = "cni"
  chart      = "cni"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.istio.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"

  values = [
    yamlencode({
      fullnameOverride = "istiod"
      profile          = "ambient"
    })
  ]

  depends_on = [
    helm_release.istiod
  ]
}

resource "helm_release" "ztunnel" {
  name       = "ztunnel"
  chart      = "ztunnel"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.istio.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"

  depends_on = [
    helm_release.cni
  ]
}
