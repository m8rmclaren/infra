output "postgres_hostname" {
  value       = "${local.name}.${var.destination_namespace}.svc.cluster.local"
  description = "The in-cluster hostname of Postgres"
}

