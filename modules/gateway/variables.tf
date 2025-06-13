variable "domain" {
  type        = string
  description = "Primary domain for the Gateway listeners"
}

variable "cluster_issuer" {
  type        = string
  description = "ClusterIssuer name for cert-manager"
}
