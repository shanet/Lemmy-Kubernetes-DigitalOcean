terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "domain" {}
variable "domain_id" {}

locals {
  subdomain = "mail"
}

resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = "${local.subdomain}.${var.domain}"
}

resource "digitalocean_record" "ses_verification" {
  domain = var.domain_id
  name   = "_amazonses.${var.domain}."
  type   = "TXT"
  value  = aws_ses_domain_identity.this.verification_token
}

resource "digitalocean_record" "dkim_records" {
  # I guess there's always three of these? We can't use `length()` here since the length
  # isn't known until the DKIM resource is created and Terraform no-likey dynamic counts.
  count = 3

  domain = var.domain_id
  name   = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey"
  type   = "CNAME"
  value  = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com."
}

resource "digitalocean_record" "spf_txt" {
  domain = var.domain_id
  name   = local.subdomain
  type   = "TXT"
  value  = "v=spf1 include:amazonses.com -all."
}

resource "digitalocean_record" "spf_mx" {
  domain   = var.domain_id
  name     = local.subdomain
  priority = "10"
  type     = "MX"
  value    = "feedback-smtp.us-west-2.amazonses.com."
}
