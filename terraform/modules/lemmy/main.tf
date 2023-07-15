terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

locals {
  namespace = kubernetes_namespace.namespace.metadata[0].name
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = replace(var.domain, ".", "-")
  }
}

resource "random_password" "pictrs_api_key" {
  length  = 30
  special = false
}
