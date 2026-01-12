variable "acme_email" {
  type        = string
  description = "Email for Let's Encrypt ACME account"
}

variable "route53_hosted_public_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID that contains your DNS zone (public zone for public certs)"
}

variable "argocd_hostname" {
  type    = string
  default = "argocd"
}

data "aws_route53_zone" "this" {
  zone_id = var.route53_hosted_public_zone_id
}

locals {
  route53_zone_name = trimsuffix(data.aws_route53_zone.this.name, ".")
}
