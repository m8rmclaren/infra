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

resource "kubernetes_namespace_v1" "gateway" {
  metadata {
    name = "gateway"
  }
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "gateway"
      namespace = kubernetes_namespace_v1.gateway.metadata[0].name
      annotations = {
        "service.beta.kubernetes.io/port_80_health-probe_protocol"  = "tcp"
        "service.beta.kubernetes.io/port_443_health-probe_protocol" = "tcp"
        "cert-manager.io/cluster-issuer"                            = var.cluster_issuer
      }
    }
    spec = {
      gatewayClassName = "istio"
      listeners = [
        {
          name     = "http"
          hostname = var.domain
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
        {
          name     = "https"
          hostname = var.domain
          port     = 443
          protocol = "HTTPS"
          tls = {
            mode = "Terminate"
            certificateRefs = [
              {
                kind  = "Secret"
                name  = "tls"
                group = ""
              }
            ]
            options = {
              minProtocolVersion = "TLSv1_2"
              maxProtocolVersion = "TLSv1_3"
              cipherSuites       = "EHE-ECDSA-AES128-GCM-SHA256,ECDHE-RSA-AES128-GCM-SHA256,ECDHE-ECDSA-AES128-SHA,AES128-GCM-SHA256,AES128-SHA,ECDHE-ECDSA-AES256-GCM-SHA384,ECDHE-RSA-AES256-GCM-SHA384,ECDHE-ECDSA-AES256-SHA,AES256-GCM-SHA384,AES256-SHA"
            }
          }
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
        {
          name     = "http-wildcard"
          hostname = "*.${var.domain}"
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
        {
          name     = "https-wildcard"
          hostname = "*.${var.domain}"
          port     = 443
          protocol = "HTTPS"
          tls = {
            mode = "Terminate"
            certificateRefs = [
              {
                kind  = "Secret"
                name  = "wildcard-tls"
                group = ""
              }
            ]
            options = {
              minProtocolVersion = "TLSv1_2"
              maxProtocolVersion = "TLSv1_3"
              cipherSuites       = "EHE-ECDSA-AES128-GCM-SHA256,ECDHE-RSA-AES128-GCM-SHA256,ECDHE-ECDSA-AES128-SHA,AES128-GCM-SHA256,AES128-SHA,ECDHE-ECDSA-AES256-GCM-SHA384,ECDHE-RSA-AES256-GCM-SHA384,ECDHE-ECDSA-AES256-SHA,AES256-GCM-SHA384,AES256-SHA"
            }
          }
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }
}

