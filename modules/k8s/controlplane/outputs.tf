output "control_plane_ip" {
  value = digitalocean_droplet.control_plane.ipv4_address
}

output "kubeconfig" {
  value = "/tmp/kubeconfig"
}
