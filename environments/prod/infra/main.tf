terraform {
  required_version = ">= v1.12.0"
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

locals {
  do_region = "sfo2"
}

provider "digitalocean" {} # token set by DIGITALOCEAN_TOKEN

provider "remote" {
  max_sessions = 2
}

resource "tls_private_key" "primary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "primary" {
  name       = "main"
  public_key = tls_private_key.primary.public_key_openssh
}

resource "digitalocean_vpc" "k8s" {
  name     = "k8s-vpc"
  region   = local.do_region
  ip_range = "10.0.4.0/22"
}

resource "digitalocean_reserved_ip" "primary" {
  region = local.do_region
}

module "controlplane" {
  source       = "../../../modules/controlplane"
  region       = local.do_region
  droplet_size = "s-1vcpu-2gb-70gb-intel"
  # droplet_size = "s-1vcpu-2gb"
  # droplet_size = "s-2vcpu-4gb"
  ssh_key_id = digitalocean_ssh_key.primary.id
  ssh_key    = tls_private_key.primary.private_key_openssh
  vpc_uuid   = digitalocean_vpc.k8s.id
  public_ip  = digitalocean_reserved_ip.primary.ip_address
}

output "kubeconfig" {
  value     = module.controlplane.kubeconfig
  sensitive = true
}

output "public_ip" {
  value = digitalocean_reserved_ip.primary.ip_address
}
