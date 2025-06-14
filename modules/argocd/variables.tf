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

variable "cluster_issuer" {
  type        = string
  description = "ClusterIssuer name for cert-manager"
}

variable "hostname" {
  type        = string
  description = "Hostname for accessing Argo CD via Gateway API"
}

variable "gateway_name" {
  type        = string
  description = "Name of the Gateway resource that will route traffic to Argo CD."
  default     = ""
}

variable "gateway_namespace" {
  type        = string
  description = "Namespace of the Gateway resource"
  default     = ""
}

variable "github_org" {
  type        = string
  description = "The name of the github organization that argocd will be configured to implicitly auth to"
}

variable "gitops_repository_name" {
  type        = string
  description = "The name of the github repo used for gitops within github_org"
}

