output "gateway_name" {
  value = kubernetes_manifest.gateway.manifest.metadata.name
}

output "gateway_namespace" {
  value = kubernetes_namespace_v1.gateway.metadata[0].name
}

