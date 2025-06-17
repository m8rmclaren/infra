variable "argocd_namespace" {
  type        = string
  description = "The namespace where ArgoCD is deployed"
}

variable "destination_server" {
  type        = string
  description = "The destination Kubernetes cluster to deploy the website to"
  default     = "https://kubernetes.default.svc"
}

variable "cluster_issuer" {
  type        = string
  description = "ClusterIssuer name for cert-manager"
}

variable "github_email" {
  type        = string
  description = "The email associated with github_token - used to create GHCR regcred"
}

variable "github_token" {
  type        = string
  description = "A Github PAT with registry access - used to create GHCR regcred"
  sensitive   = true
}

variable "domain" {
  type        = string
  description = "Base domain of the website"
}

variable "ip_address" {
  description = "The IP address the A records should point to"
  type        = string
}

variable "gitops_repo" {
  type        = string
  description = "Git URL (or other) to the GitOps repo containing the stage and prod Helm chart"
}

variable "path_to_stage_manifests" {
  type        = string
  description = "The path to the Helm chart containing the staging Helm chart"
}

variable "path_to_prod_manifests" {
  type        = string
  description = "The path to the Helm chart containing the prod Helm chart"
}

