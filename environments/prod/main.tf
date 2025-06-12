terraform {
  required_version = ">= v1.12.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {} # token set by DIGITALOCEAN_TOKEN

data "digitalocean_project" "default" {
}
