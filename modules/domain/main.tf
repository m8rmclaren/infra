terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

locals {
  name = var.subdomain == "" ? var.domain : "${var.subdomain}.${var.domain}"
}

data "cloudflare_zones" "selected" {
  name = var.domain
}

resource "cloudflare_dns_record" "domain" {
  zone_id = data.cloudflare_zones.selected.result[0].id
  name    = local.name
  type    = "A"
  content = var.ip_address
  ttl     = var.ttl
  proxied = var.proxied
  tags    = []
}
