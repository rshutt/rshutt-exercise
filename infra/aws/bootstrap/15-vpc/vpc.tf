data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  vpc_cidr = "10.42.0.0/16"

  # Two public and two private subnets across 2 AZs
  public_subnet_cidrs  = ["10.42.0.0/20", "10.42.16.0/20"]
  private_subnet_cidrs = ["10.42.32.0/20", "10.42.48.0/20"]
}

resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.vpn_name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpn_name}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for idx, az in local.azs : az => {
      cidr = local.public_subnet_cidrs[idx]
      az   = az
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpn_name}-public-${each.value.az}"

    # EKS subnet discovery tags
    "kubernetes.io/cluster/${var.vpn_name}" = "shared"
    "kubernetes.io/role/elb"                = "1"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for idx, az in local.azs : az => {
      cidr = local.private_subnet_cidrs[idx]
      az   = az
    }
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.vpn_name}-private-${each.value.az}"

    # EKS subnet discovery tags
    "kubernetes.io/cluster/${var.vpn_name}" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.vpn_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[local.azs[0]].id

  tags = {
    Name = "${var.vpn_name}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpn_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.vpn_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
