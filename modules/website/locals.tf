locals {
  name            = "website"
  stage_subdomain = "stage"

  stage_namespace = "website-staging"
  prod_namespace  = "website-prod"

  ghcr_pull_secret = "regcred"

  securityContext = {
    capabilities = {
      drop = ["ALL"]
    }
    readOnlyRootFilesystem = true
    runAsNonRoot           = true
    runAsUser              = 1000
  }
}


