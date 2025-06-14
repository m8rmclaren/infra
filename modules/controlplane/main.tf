terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    remote = {
      source  = "tmscer/remote"
      version = "0.2.2"
    }
  }
}

# Deploy a DO droplet
resource "digitalocean_droplet" "control_plane" {
  name   = "k8s-control-plane"
  image  = "ubuntu-22-04-x64"
  region = var.region
  size   = var.droplet_size

  vpc_uuid = var.vpc_uuid

  ssh_keys = [var.ssh_key_id]
  user_data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    reserved_ip     = var.public_ip
    kubeconfig_path = local.kubectl_path
  })

  monitoring = true

  tags = ["k8s", "control-plane"]
}

locals {
  kubectl_path = "/root/kubeconfig"
}

# Wait for droplet to come online and its tasks to finish
resource "null_resource" "wait_for_droplet" {
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.control_plane.ipv4_address
    user        = "root"
    private_key = var.ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",                          # Waits until cloud-init finishes
      "cloud-init status",                                 # Should output: status: done
      "test -f /var/lib/cloud/instance/user-data.success", # cloud-init.yaml writes this file when finished
      "echo Cloud-init completed successfully"
    ]
  }

  depends_on = [digitalocean_droplet.control_plane]

  triggers = {
    droplet_id     = digitalocean_droplet.control_plane.id
    droplet_ip     = digitalocean_droplet.control_plane.ipv4_address
    droplet_status = digitalocean_droplet.control_plane.status
  }
}

# Bind static IP
resource "digitalocean_reserved_ip_assignment" "public_ip" {
  droplet_id = digitalocean_droplet.control_plane.id
  ip_address = var.public_ip

  depends_on = [null_resource.wait_for_droplet]
}

data "remote_file" "kubeconfig" {
  conn {
    host        = digitalocean_droplet.control_plane.ipv4_address
    user        = "root"
    private_key = var.ssh_key
  }

  path = local.kubectl_path

  depends_on = [null_resource.wait_for_droplet]
}
