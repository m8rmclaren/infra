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

resource "kubernetes_namespace_v1" "istio" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = "istio-system"
  }
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
