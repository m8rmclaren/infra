variable "chart_version" {
  type        = string
  description = "The version of the Argo CD Helm chart to install"
}

variable "cluster_issuer" {
  type        = string
  description = "Name of the cert-manager ClusterIssuer that will be created"
}

variable "acme_server" {
  type        = string
  description = "The ACME server URL (e.g., Let's Encrypt Staging or Production)"
}

variable "email" {
  type        = string
  description = "Email address used for ACME registration"
}

variable "domain" {
  type        = string
  description = "The DNS domain name managed by Cloudflare"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  sensitive   = true
}
