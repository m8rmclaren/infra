locals {
  name            = "website"
  stage_subdomain = "stage"

  stage_namespace = "website-staging"
  prod_namespace  = "website-prod"

  ghcr_pull_secret = "regcred"

  path_to_stage_manifests = "dev/website"
  path_to_prod_manifests  = "prod/website"

  securityContext = {
    capabilities = {
      drop = ["ALL"]
    }
    readOnlyRootFilesystem = true
    runAsNonRoot           = true
    runAsUser              = 1000
  }
}


