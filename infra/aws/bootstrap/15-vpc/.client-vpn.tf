##############################
# Client VPN + Identity Center
##############################

variable "client_vpn_cidr" {
  description = "CIDR for VPN clients (must not overlap VPC/on-prem)."
  type        = string
  default     = "10.250.0.0/22"
}

variable "idc_metadata_file" {
  description = "Path to IAM Identity Center IdP metadata XML."
  type        = string
  default     = "./idc-metadata.xml"
}

locals {
  # AmazonProvidedDNS = VPC base + 2
  vpc_dns = cidrhost(aws_vpc.this.cidr_block, 2)
}

resource "aws_iam_saml_provider" "idc" {
  name                   = "${var.vpn_name}-idc-saml"
  saml_metadata_document = file(var.idc_metadata_file)
}

resource "tls_private_key" "vpn_server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "vpn_server" {
  private_key_pem = tls_private_key.vpn_server.private_key_pem

  subject {
    common_name  = "${var.vpn_name}.clientvpn"
    organization = "terraform"
  }

  validity_period_hours = 24 * 365 * 3
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
  dns_names             = ["${var.vpn_name}.clientvpn"]
}

resource "aws_acm_certificate" "vpn_server" {
  private_key       = tls_private_key.vpn_server.private_key_pem
  certificate_body  = tls_self_signed_cert.vpn_server.cert_pem
  certificate_chain = tls_self_signed_cert.vpn_server.cert_pem

  tags = { Name = "${var.vpn_name}-clientvpn-server-cert" }
}

resource "aws_security_group" "client_vpn" {
  name        = "${var.vpn_name}-clientvpn-sg"
  description = "Client VPN security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Client VPN listener (UDP 443)"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Client VPN listener (TCP 443)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.vpn_name}-clientvpn-sg" }
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.vpn_name} client vpn"
  server_certificate_arn = aws_acm_certificate_validation.clientvpn.certificate_arn
  client_cidr_block      = var.client_vpn_cidr

  transport_protocol = "udp"
  split_tunnel       = true
  dns_servers        = [local.vpc_dns]

  vpc_id             = aws_vpc.this.id
  security_group_ids = [aws_security_group.client_vpn.id]

  authentication_options {
    type              = "federated-authentication"
    saml_provider_arn = aws_iam_saml_provider.idc.arn
  }

  connection_log_options {
    enabled = false
  }

  tags = { Name = "${var.vpn_name}-clientvpn" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ec2_client_vpn_network_association" "private" {
  for_each               = aws_subnet.private
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value.id
}

#resource "aws_ec2_client_vpn_route" "to_vpc" {
#  for_each               = aws_ec2_client_vpn_network_association.private
#  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
#  destination_cidr_block = aws_vpc.this.cidr_block
#  target_vpc_subnet_id   = each.value.subnet_id
#}

resource "aws_ec2_client_vpn_authorization_rule" "allow_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = aws_vpc.this.cidr_block
  authorize_all_groups   = true
  description            = "Allow VPN users to reach VPC"
}

output "client_vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.this.id
}

data "aws_route53_zone" "aws_subdomain" {
  name         = "aws.randallman.net."
  private_zone = false
}

resource "aws_acm_certificate" "clientvpn" {
  domain_name       = "clientvpn.aws.randallman.net"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "clientvpn_validation" {
  for_each = {
    for dvo in aws_acm_certificate.clientvpn.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.aws_subdomain.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "clientvpn" {
  certificate_arn         = aws_acm_certificate.clientvpn.arn
  validation_record_fqdns = [for r in aws_route53_record.clientvpn_validation : r.fqdn]
}
