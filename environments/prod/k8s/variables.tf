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

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "github_email" {
  type        = string
  description = "Email associated with Github account that owns github_pat"
}

variable "github_pat" {
  type        = string
  description = "Github PAT (must have repo scope)"
  sensitive   = true
}

