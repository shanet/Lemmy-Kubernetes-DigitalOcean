variable "digitalocean_spaces_access_key" {}
variable "digitalocean_spaces_secret_key" {}
variable "domain" {}
variable "environment" {}
variable "region" {}

locals {
  name_prefix = "lemmy-${var.environment}"
}

module "certificate" {
  source = "../certificate"

  domains     = [var.domain, "*.${var.domain}"]
  name_prefix = local.name_prefix
}

module "database" {
  source = "../database"

  kubernetes_cluster_id = module.kubernetes_cluster.cluster.id
  name_prefix           = local.name_prefix
  region                = var.region
}

module "dns" {
  source = "../dns"

  domain                   = var.domain
  load_balancer_ip_address = module.lemmy.nginx_ip
}

module "iam" {
  source = "../iam"

  name_prefix = local.name_prefix
}

module "lemmy" {
  source = "../lemmy"

  certificate_id            = module.certificate.certificate.uuid
  database_host             = "${module.database.database_cluster.private_host}:${module.database.database_cluster.port}"
  database_name             = module.database.database_name
  database_password         = module.database.database_cluster.password
  database_username         = module.database.database_cluster.user
  domain                    = var.domain
  name_prefix               = local.name_prefix
  pictrs_storage_access_key = var.digitalocean_spaces_access_key
  pictrs_storage_secret_key = var.digitalocean_spaces_secret_key
  region                    = var.region
  smtp_host                 = "email-smtp.us-west-2.amazonaws.com:465"
  smtp_password             = module.iam.smtp_password
  smtp_username             = module.iam.smtp_username
}

module "kubernetes_cluster" {
  source = "../kubernetes_cluster"

  name_prefix = local.name_prefix
  region      = var.region
}

module "ses" {
  source = "../ses"

  domain    = var.domain
  domain_id = module.dns.domain.id
}

output "kubernetes_cluster" {
  value = module.kubernetes_cluster.cluster
}
