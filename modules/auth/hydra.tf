locals {
  hydra = {
    fullnameOverride = "${local.name}-hydra"
    deployment = {
      labels = {
        "app.kubernetes.io/app" = "hydra"
      }
      extraEnv = [
        {
          name = "DSN"
          valueFrom = {
            secretKeyRef = {
              name = local.secret_name
              key  = local.hydra_dsn_key
            }
          }
        }
      ]
    }
    secret = {
      enabled      = false
      nameOverride = local.secret_name
    }
    hydra = {
      automigration = {
        enabled = true
        type    = "initContainer"
      }
      config = {
        urls = {
          self = {
            issuer = "https://${local.auth_hostname}"
          }
          login   = "https://${local.auth_hostname}/consent/login"
          consent = "https://${local.auth_hostname}/consent/consent"
        }
      }
      strategies = {
        // https://www.ory.sh/docs/oauth2-oidc/jwt-access-token#jwt-access-tokens
        access_token = "jwt"
      }
      // https://www.ory.sh/docs/oauth2-oidc/jwt-access-token#disable-mirroring-the-claims-under-ext
      oauth2 = {
        allowed_top_level_claims = [
          "oid"
        ]
        mirror_top_level_claims = false
      }
    }
  }
}
