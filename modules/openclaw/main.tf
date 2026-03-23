terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_droplet" "openclaw" {
  name   = "openclaw"
  image  = "ubuntu-22-04-x64"
  region = var.region
  size   = var.droplet_size

  vpc_uuid = var.vpc_uuid

  ssh_keys    = [var.ssh_key_id]
  resize_disk = false

  monitoring = true

  tags = ["openclaw"]
}

# Wait for droplet to come online
resource "null_resource" "wait_for_droplet" {
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.openclaw.ipv4_address
    user        = "root"
    private_key = var.ssh_key
  }

  provisioner "remote-exec" {
    inline = ["echo Droplet is ready"]
  }

  depends_on = [digitalocean_droplet.openclaw]

  triggers = {
    droplet_id     = digitalocean_droplet.openclaw.id
    droplet_ip     = digitalocean_droplet.openclaw.ipv4_address
    droplet_status = digitalocean_droplet.openclaw.status
  }
}

# Bind static IP
resource "digitalocean_reserved_ip_assignment" "public_ip" {
  droplet_id = digitalocean_droplet.openclaw.id
  ip_address = var.public_ip

  depends_on = [null_resource.wait_for_droplet]
}
