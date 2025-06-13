variable "chart_version" {
  type        = string
  description = "The version of the Argo CD Helm chart to install"
}

variable "replicas" {
  type        = number
  description = "The number of istiod replicas to create"
}
