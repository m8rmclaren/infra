locals {
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
      config = {
        identity = {
          schemas = [
            {
              id  = "user_v1"
              url = "base64://${filebase64("${path.module}/identity.schema.json")}"
            }
          ]
        }
      }
    }
  }
}
