data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  vpc_name = data.aws_vpc.vpc.tags.Name
  tags     = merge(var.tags, { vpc_name = local.vpc_name })
}

module "subnets" {
  source             = "../subnets"
  vpc_id             = var.vpc_id
  availability_zones = var.availability_zones
  force_cidr_ranges  = var.force_cidr_ranges
  tags               = var.tags
  width              = var.width
  offset             = var.offset
  tier               = "public"
  name               = "public"
}

resource "aws_eip" "this" {
  for_each = var.availability_zones
  domain   = "vpc"
  tags = merge(
    local.tags,
    { Name = "${local.vpc_name}-public-nat-eip-${each.key}" },
  )
  # Prevent accidental deletion of EIPs
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags = merge(
    local.tags,
    { Name = "${local.vpc_name}-igw" },
  )
}

resource "aws_nat_gateway" "this" {
  for_each      = var.availability_zones
  allocation_id = aws_eip.this[each.key].allocation_id
  subnet_id     = module.subnets.subnets[each.key].subnet_id

  tags = merge(
    local.tags,
    { Name = "${local.vpc_name}-public-nat-${each.key}" },
  )
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "this" {
  for_each               = var.availability_zones
  route_table_id         = module.subnets.subnets[each.key].route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
