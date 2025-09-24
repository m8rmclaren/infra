locals {
  name = "auth"

  path_to_manifests = "infra/auth"

  secret_name = "config"

  hydra_dsn_key  = "hydra_dsn"
  kratos_dsn_key = "kratos_dsn"

  securityContext = {
    capabilities = {
      drop = ["ALL"]
    }
    readOnlyRootFilesystem = true
    runAsNonRoot           = true
    runAsUser              = 1000
  }
}

