terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
  }
}

locals {
  docker_auth_raw = "${var.github_email}:${var.github_token}"
  docker_auth_b64 = base64encode(local.docker_auth_raw)

  docker_config = jsonencode({
    auths = {
      "ghcr.io" = {
        auth = local.docker_auth_b64
      }
    }
  })
}

resource "kubernetes_secret_v1" "ghcr" {
  metadata {
    name      = var.secret_name
    namespace = var.namespace
  }

  data = {
    ".dockerconfigjson" = local.docker_config
  }

  type = "kubernetes.io/dockerconfigjson"
}

