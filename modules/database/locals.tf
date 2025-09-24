locals {
  name = "database"

  path_to_manifests = "infra/database"

  postgres_secret_name = "postgres-passwords"

  postgres_password_key             = "POSTGRES_PASSWORD"
  postgres_replication_password_key = "replication-password"

  hydra_password_key  = "HYDRA_PASSWORD"
  kratos_password_key = "KRATOS_PASSWORD"

  securityContext = {
    capabilities = {
      drop = ["ALL"]
    }
    readOnlyRootFilesystem = true
    runAsNonRoot           = true
    runAsUser              = 1000
  }
}

