terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "domain" {}
variable "load_balancer_ip_address" {}

resource "digitalocean_domain" "domain" {
  name = var.domain
}

resource "digitalocean_record" "apex" {
  domain = digitalocean_domain.domain.id
  name   = "@"
  type   = "A"
  value  = var.load_balancer_ip_address
}

output "domain" {
  value = digitalocean_domain.domain
}
