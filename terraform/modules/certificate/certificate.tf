terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "domains" {type = list(string)}
variable "name_prefix" {}

resource "digitalocean_certificate" "certificate" {
  domains = var.domains
  name    = var.name_prefix
  type    = "lets_encrypt"
}

output "certificate" {
  value = digitalocean_certificate.certificate
}
