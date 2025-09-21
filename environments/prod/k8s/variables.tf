variable "email" {
  type        = string
  description = "Email used for Let's Encrypt"
}

variable "domain" {
  type        = string
  description = "Primary top level domain"
}

variable "kubeconfig" {
  type        = string
  description = "Path to kubeconfig"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "github_email" {
  type        = string
  description = "Email associated with Github account that owns github_pat"
}

variable "github_pat" {
  type        = string
  description = "Github PAT (must have repo scope)"
  sensitive   = true
}

variable "postgres_admin_password" {
  type        = string
  description = "The admin password for the Postgres database"
  sensitive   = true
}

variable "postgres_replication_password" {
  type        = string
  description = "The replication password for the Postgres database"
  sensitive   = true
}

variable "hydra_database_password" {
  type        = string
  description = "The password for the Hydra database in Postgres"
  sensitive   = true
}
