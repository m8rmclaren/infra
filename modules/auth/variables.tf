#########################################
# ArgoCD Config (AppProj & Application) #
#########################################

variable "argocd_namespace" {
  type        = string
  description = "The namespace where ArgoCD is deployed - AppProj deployed in this ns"
}

variable "destination_server" {
  type        = string
  description = "The destination Kubernetes cluster to deploy Hydra to to"
  default     = "https://kubernetes.default.svc"
}

variable "destination_namespace" {
  type        = string
  description = "The destination namespace to deploy Hydra in"
  default     = "database"
}

variable "gitops_repo" {
  type        = string
  description = "Git URL (or other) to the GitOps repo containing the stage and prod Helm chart"
}

#########################################
# Database                              #
#########################################

variable "postgres_hostname" {
  description = "Hostname of Postgres database"
  type        = string
}

############################
# Kratos Database Config   #
############################

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

############################
# Hydra Database Config    #
############################

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

############################
# Hydra Secret Config      #
############################

variable "hydra_system_secret" {
  description = "Hydra system secret"
  type        = string
  sensitive   = true
}

variable "hydra_cookie_secret" {
  description = "Hydra cookie secret"
  type        = string
  sensitive   = true
}

############################
# Networking/application   #
############################

variable "domain" {
  type        = string
  description = "Base domain"
}

variable "subdomain" {
  type        = string
  description = "Subdomain used to construct auth hostname - e.g. 'auth' would result in auth.<domain>"
}

variable "ip_address" {
  description = "The IP address the A records should point to"
  type        = string
}

variable "cluster_issuer" {
  type        = string
  description = "ClusterIssuer name for cert-manager"
}

####################################
# Identity & Social Sign in Config #
####################################

variable "apple_developer_team_id" {
  description = "10-character Team ID associated with your developer account"
  type        = string
  sensitive   = true
}

variable "chat_siwa_primary_app_id" {
  description = "Primary App ID of the Chat App in Apple Developer"
  type        = string
  sensitive   = true
}
