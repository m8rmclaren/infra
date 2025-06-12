terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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

  ssh_keys  = [var.ssh_key_id]
  user_data = file("${path.module}/cloud-init.yaml")

  monitoring = true

  tags = ["k8s", "control-plane"]
}

# Wait for droplet to come online and its tasks to finish
resource "null_resource" "wait_for_droplet" {
  depends_on = [digitalocean_droplet.control_plane]

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

  provisioner "remote-exec" {
    inline = [
      "microk8s config > /root/kubeconfig"
    ]
  }
}

# Bind static IP
resource "digitalocean_reserved_ip_assignment" "public_ip" {
  droplet_id = digitalocean_droplet.control_plane.id
  ip_address = var.public_ip

  depends_on = [null_resource.wait_for_droplet]
}

# Install the Gateway API CRDs
resource "null_resource" "install_gateway_api_crds" {
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.control_plane.ipv4_address
    user        = "root"
    private_key = var.ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "microk8s kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
    ]
  }

  depends_on = [null_resource.wait_for_droplet]
}

resource "null_resource" "get_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      echo "${var.ssh_key}" > /tmp/temp_ssh_key && \
      chmod 600 /tmp/temp_ssh_key && \
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/temp_ssh_key root@${digitalocean_droplet.control_plane.ipv4_address}:/root/kubeconfig /tmp/ && \
      rm /tmp/temp_ssh_key
    EOT
  }

  triggers = {
    always_run = timestamp() # This forces recreation on every `apply`
  }

  depends_on = [null_resource.wait_for_droplet]
}

