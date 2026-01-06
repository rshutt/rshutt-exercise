variable "acme_email" {
  type        = string
  description = "Email for Let's Encrypt ACME account"
}

variable "route53_hosted_public_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID that contains your DNS zone (public zone for public certs)"
}

data "aws_route53_zone" "this" {
  zone_id = var.route53_hosted_public_zone_id
}

locals {
  route53_zone_name = trimsuffix(data.aws_route53_zone.this.name, ".")
}

variable "nlb_eip_allocation_ids" {
  type        = list(string)
  description = "Optional list of EIP allocation IDs, one per AZ/subnet used by the NLB"
  default     = []
}

# Optional: explicitly force which subnets the NLB uses (recommended if you want deterministic AZ/EIP mapping)
variable "nlb_subnet_ids" {
  type        = list(string)
  description = "Optional list of subnet IDs for the NLB"
  default     = []
}
