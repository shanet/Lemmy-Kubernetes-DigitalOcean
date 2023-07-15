terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "name_prefix" {}
variable "region" {}
variable "size" { default = "s-1vcpu-2gb" }

resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.name_prefix
  region  = var.region
  version = "1.27.2-do.0"

  node_pool {
    name       = var.name_prefix
    node_count = 1
    size       = var.size
  }
}

output "cluster" {
  value = digitalocean_kubernetes_cluster.cluster
}
