resource "aws_ec2_tag" "public_cluster" {
  for_each    = toset(local.public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_role" {
  for_each    = toset(local.public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_cluster" {
  for_each    = toset(local.private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_role" {
  for_each    = toset(local.private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}
