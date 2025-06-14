variable "email" {
  type        = string
  description = "Email used for Let's Encrypt"
}

variable "domain" {
  type        = string
  description = "Primary top level domain"
}

variable "kubeconfig" {
  type        = string
  description = "Path to kubeconfig"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  sensitive   = true
}

variable "github_pat" {
  type        = string
  description = "Github PAT (must have repo scope)"
  sensitive   = true
}

