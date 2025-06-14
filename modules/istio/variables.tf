variable "gateway_api_version" {
  type        = string
  description = "The Kubernetes Gateway API version to install"
  default     = "v1.3.0"
}

variable "chart_version" {
  type        = string
  description = "The version of the Argo CD Helm chart to install"
}

variable "replicas" {
  type        = number
  description = "The number of istiod replicas to create"
}
