variable "certificate_id" {}
variable "database_host" {}
variable "database_name" {}
variable "database_password" {}
variable "database_username" {}
variable "pictrs_storage_access_key" {}
variable "pictrs_storage_secret_key" {}
variable "domain" {}
variable "name_prefix" {}
variable "region" {}
variable "smtp_host" {}
variable "smtp_password" {}
variable "smtp_username" {}
variable "version_lemmy" { default = "0.18.2" }
variable "version_nginx" { default = "1-alpine" }
variable "version_pictrs" { default = "0.4.0-rc.7" }
