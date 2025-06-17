variable "application_name" {}

variable "destination_namespace" {}

variable "destination_server" {
  type        = string
  description = "The destination Kubernetes cluster to deploy the app to"
  default     = "https://kubernetes.default.svc"
}

variable "application_annotations" {
  type    = map(string)
  default = {}
}

variable "repo" {
  type        = string
  description = "Git URL (or other) to the Helm chart that the Application resource will deploy & maintain"
}

variable "project" {
  type        = string
  description = "The name of the ArgoCD project to deploy the app inside of"
  default     = "default"
}

variable "path_to_manifests" {}

variable "revision" {
  type    = string
  default = "HEAD"
}

variable "values" {
  type        = any
  description = "The Helm chart values file -> converted to YAML implicitly"
  default     = null
}

variable "sync_policy" {
  type = any
}
