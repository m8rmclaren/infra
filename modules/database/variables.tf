variable "argocd_namespace" {
  type        = string
  description = "The namespace where ArgoCD is deployed - AppProj deployed in this ns"
}

variable "destination_server" {
  type        = string
  description = "The destination Kubernetes cluster to deploy Postgres to to"
  default     = "https://kubernetes.default.svc"
}

variable "destination_namespace" {
  type        = string
  description = "The destination namespace to deploy Postgres in"
  default     = "database"
}

variable "gitops_repo" {
  type        = string
  description = "Git URL (or other) to the GitOps repo containing the stage and prod Helm chart"
}

variable "postgres_admin_password" {
  description = "Postgres admin password."
  type        = string
  sensitive   = true
}

variable "postgres_replication_password" {
  description = "Postgres replication password."
  type        = string
  sensitive   = true
}

variable "hydra_database_name" {
  description = "Hydra DB name."
  type        = string
}

variable "hydra_database_username" {
  description = "Hydra DB username."
  type        = string
}

variable "hydra_database_password" {
  description = "Hydra DB password."
  type        = string
  sensitive   = true
}

variable "kratos_database_name" {
  description = "Kratos DB name."
  type        = string
}

variable "kratos_database_username" {
  description = "Kratos DB username."
  type        = string
}

variable "kratos_database_password" {
  description = "Kratos DB password."
  type        = string
  sensitive   = true
}
