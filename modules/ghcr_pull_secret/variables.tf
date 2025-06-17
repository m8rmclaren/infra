variable "namespace" {
  type        = string
  description = "The namespace to create the secret in"
}

variable "secret_name" {
  type        = string
  description = "The name of the Kubernetes secret"
}

variable "github_email" {
  type        = string
  description = "The GitHub email used for GHCR auth"
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "The GitHub token used for GHCR auth"
  sensitive   = true
}
