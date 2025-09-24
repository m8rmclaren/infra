locals {
  cors = {
    enabled = true
    allowed_origins = [
      "https://${var.domain}",
      "https://*.${var.domain}"
    ]
    allowed_methods = ["POST", "GET", "PUT", "PATCH", "DELETE"]
    allowed_headers = ["Authorization", "Cookie", "Content-Type"]
    exposed_headers = ["Content-Type", "Set-Cookie"]
  }

  # https://www.ory.sh/docs/kratos/social-signin/apple
  # Apple OIDC provider specifically for the Chat App ID SIWA functionality
  # This is a non-browser flow; Kratos never calls Apple & just validates ID Token -> mints Session
  apple_provider_config = {
    id                   = "chat_siwa"
    provider             = "apple"
    client_id            = var.chat_siwa_primary_app_id
    apple_team_id        = var.apple_developer_team_id
    apple_private_key_id = "none"
    apple_private_key    = "none"
    issuer_url           = "https://appleid.apple.com"
    mapper_url           = "base64://${filebase64("${path.module}/identity/apple.data-mapper.jsonnet")}"
    scope                = ["email"]
  }

  # https://www.ory.sh/docs/kratos/reference/configuration
  kratos_config = {
    log = {
      leak_sensitive_values = true
    }
    identity = {
      schemas = [
        {
          id                     = "default"
          url                    = "base64://${filebase64("${path.module}/identity/identity.schema.json")}"
          selfservice_selectable = true # https://www.ory.sh/docs/identities/model/identity-schema-selection#configuration
        },
        {
          id                     = "user_v1"
          url                    = "base64://${filebase64("${path.module}/identity/identity.schema.json")}"
          selfservice_selectable = true # https://www.ory.sh/docs/identities/model/identity-schema-selection#configuration
        }
      ]
    }
    serve = {
      public = {
        base_url = "https://${local.auth_hostname}"
        cors     = local.cors
      }
    }
    selfservice = {
      methods = {
        oidc = {
          enabled = true
          config = {
            providers = [
              local.apple_provider_config
            ]
          }
        }
      }
    }
  }

  kratos = {
    fullnameOverride = "${local.name}-kratos"
    deployment = {
      labels = {
        "app.kubernetes.io/app" = "kratos"
      }
      extraEnv = [
        {
          name = "DSN"
          valueFrom = {
            secretKeyRef = {
              name = local.secret_name
              key  = local.kratos_dsn_key
            }
          }
        }
      ]
    }
    secret = {
      enabled      = false
      nameOverride = local.secret_name
    }
    kratos = {
      automigration = {
        enabled = true
        type    = "initContainer"
      }
      config = local.kratos_config
    }
  }
}
