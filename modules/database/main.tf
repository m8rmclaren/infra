terraform {
  required_version = ">= v1.12.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

resource "kubectl_manifest" "argo_appproject" {
  validate_schema = false

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = local.name
      namespace = var.argocd_namespace
    }
    spec = {
      sourceNamespaces = [var.destination_namespace]
      sourceRepos      = [var.gitops_repo]
      destinations = [
        {
          server    = var.destination_server
          namespace = var.destination_namespace
        },
      ]
    }
  })
}

resource "kubernetes_namespace_v1" "database" {
  metadata {
    labels = {
      deployedBy = "infra"
    }

    name = var.destination_namespace
  }
}

resource "kubernetes_secret_v1" "postgres_database_secret" {
  metadata {
    name      = local.postgres_secret_name
    namespace = var.destination_namespace
  }

  type = "Opaque"

  data = {
    (local.postgres_password_key)             = var.postgres_admin_password
    (local.postgres_replication_password_key) = var.postgres_replication_password
    (local.hydra_password_key)                = var.hydra_database_password
  }
}

module "website_prod" {
  source = "../argo_helm_app"

  project  = local.name
  revision = "HEAD"

  application_name      = local.name
  destination_namespace = var.destination_namespace
  repo                  = var.gitops_repo
  path_to_manifests     = local.path_to_manifests
  sync_policy = {
    automated = {
      prune    = true
      selfHeal = true
    }
  }

  values = {
    # https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values
    valuesObject = {
      fullnameOverride = local.name
      postgresql = {
        fullnameOverride = local.name
        auth = {
          enablePostgresUser  = true
          replicationUsername = "repl-user"
          existingSecret      = local.postgres_secret_name
          secretKeys = {
            adminPasswordKey       = local.postgres_password_key
            replicationPasswordKey = local.postgres_replication_password_key
          }
        }
        primary = {
          extraEnvVarsSecret = local.postgres_secret_name
          initdb = {
            scripts = {
              "init-user-db.sh" = <<-EOT
                #!/bin/bash
                set -e
                export PGPASSWORD="${"$"}${local.postgres_password_key}"
                psql -v ON_ERROR_STOP=1 --username "$POSTGRESQL_USERNAME" <<-EOSQL
                  CREATE DATABASE ${var.hydra_database_name};
                  CREATE USER ${var.hydra_database_username} WITH PASSWORD '${"$"}${local.hydra_password_key}';
                  GRANT ALL PRIVILEGES ON DATABASE ${var.hydra_database_name} TO ${var.hydra_database_username};

                  \\c ${var.hydra_database_name}
                  GRANT USAGE, CREATE ON SCHEMA public TO ${var.hydra_database_username};
                  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${var.hydra_database_username};
                EOSQL
              EOT
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.argo_appproject,
    kubernetes_namespace_v1.database,
  ]
}
