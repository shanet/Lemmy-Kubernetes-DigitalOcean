terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "kubernetes_cluster_id" {}
variable "name_prefix" {}
variable "region" {}
variable "size" {default = "db-s-1vcpu-1gb"}

resource "digitalocean_database_cluster" "cluster" {
  engine     = "pg"
  name       = var.name_prefix
  node_count = 1
  region     = var.region
  size       = var.size
  version    = "15"
}

resource "digitalocean_database_firewall" "firewall" {
  cluster_id = digitalocean_database_cluster.cluster.id

  rule {
    type  = "k8s"
    value = var.kubernetes_cluster_id
  }
}

resource "digitalocean_database_db" "database" {
  cluster_id = digitalocean_database_cluster.cluster.id
  name       = var.name_prefix
}

output "database_cluster" {
  value = digitalocean_database_cluster.cluster
}

output "database_name" {
  value = digitalocean_database_db.database.name
}
