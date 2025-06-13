variable "name" {
  type        = string
  description = "Release and namespace name"
  default     = "external-dns"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  sensitive   = true
}

variable "external_dns_version" {
  type        = string
  description = "Version of external-dns to install"
  default     = "1.16.1"
}
