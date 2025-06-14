# Generate an ssh key for the GitOps deploy key
resource "tls_private_key" "gitops" {
  algorithm = "ED25519"
}

# Add the ssh key as a deploy key
resource "github_repository_deploy_key" "gitops" {
  title      = "GitOps Deploy Key"
  repository = var.gitops_repository_name
  key        = tls_private_key.gitops.public_key_openssh
  read_only  = true
}

locals {
  github_ssh_string = "git@github.com:${var.github_org}/${var.gitops_repository_name}.git"
}

resource "kubernetes_secret" "argo_repo" {
  metadata {
    name      = var.gitops_repository_name
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    type          = "git"
    url           = local.github_ssh_string
    sshPrivateKey = tls_private_key.gitops.private_key_openssh
  }

  depends_on = [helm_release.argo_cd]
}
