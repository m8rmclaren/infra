variable "name" {
  type        = string
  description = "Release and namespace name"
  default     = "argo-cd"
}

variable "chart_version" {
  type        = string
  description = "The version of the Argo CD Helm chart to install"
}

variable "application_controller_replicas" {
  type        = number
  description = "Number of replicas for the Argo CD application controller"
}

variable "application_set_controller_replicas" {
  type        = number
  description = "Number of replicas for the Argo CD ApplicationSet controller"
}

variable "server_min_replicas" {
  type        = number
  description = "Minimum number of replicas for the Argo CD server"
}

variable "repo_server_min_replicas" {
  type        = number
  description = "Minimum number of replicas for the Argo CD repo server"
}

variable "hostname" {
  type        = string
  description = "Hostname for accessing Argo CD via Gateway API"
}

variable "gateway_name" {
  type        = string
  description = "Name of the Gateway resource that will route traffic to Argo CD"
}

variable "gateway_namespace" {
  type        = string
  description = "Namespace of the Gateway resource"
}
