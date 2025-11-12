locals {
  name = "health-auto-export-server"

  namespace = "health-auto-export-server"

  ghcr_pull_secret = "regcred"

  path_to_prod_manifests = "prod/health-auto-export-server"

  securityContext = {
    capabilities = {
      drop = ["ALL"]
    }
    readOnlyRootFilesystem = true
    runAsNonRoot           = true
    runAsUser              = 1000
  }
}


