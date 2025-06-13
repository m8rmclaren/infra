variable "kubeconfig" {
  type        = string
  description = "Path to kubeconfig"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  sensitive   = true
}

