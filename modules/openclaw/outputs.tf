output "ipv4_address" {
  value = digitalocean_droplet.openclaw.ipv4_address
}

output "public_ip" {
  value = var.public_ip
}
