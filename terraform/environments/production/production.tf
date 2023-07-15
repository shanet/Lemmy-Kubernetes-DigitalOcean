terraform {
  backend "s3" {
    bucket  = "shanet-terraform-backend"
    key     = "lemmy/production.tfstate"
    profile = "personal"
    region  = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.8.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.28.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
  }
}

variable "aws_profile" { default = "personal" }
variable "digitalocean_spaces_access_key" { sensitive = true }
variable "digitalocean_spaces_secret_key" { sensitive = true }
variable "domain" {}

provider "aws" {
  profile = var.aws_profile
  region  = "us-west-2"
}

provider "digitalocean" {
  spaces_access_id  = var.digitalocean_spaces_access_key
  spaces_secret_key = var.digitalocean_spaces_secret_key
}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.project.kubernetes_cluster.kube_config[0].cluster_ca_certificate)
  host                   = module.project.kubernetes_cluster.endpoint
  token                  = module.project.kubernetes_cluster.kube_config[0].token
}

module "project" {
  source = "../../modules/project"

  digitalocean_spaces_access_key = var.digitalocean_spaces_access_key
  digitalocean_spaces_secret_key = var.digitalocean_spaces_secret_key
  domain                         = var.domain
  environment                    = "production"
  region                         = "sfo3"
}
