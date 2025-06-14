variable "domain" {
  type        = string
  description = "Primary domain for the Gateway listeners"
}

variable "cluster_issuer" {
  type        = string
  description = "ClusterIssuer name for cert-manager"
}

variable "gateway_class" {
  type        = string
  description = "The gateway class corresponding to the Gateway Controller"
}
