output "repo_name" {
  value       = local.github_ssh_string
  description = "The URL of the GitOps repo that is configured in ArgoCD"
}

output "argocd_namespace" {
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
  description = "The namespace where ArgoCD was deployed"
}

