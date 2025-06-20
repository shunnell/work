# VPC Resource
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns
  enable_dns_support   = var.enable_dns
  instance_tenancy     = "default"
  # Dependency prevents accidental VPC creation on name conflict (since the IAM role has a static vpc-name-based name):
  depends_on = [module.flow_logs_role]
  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

# Public access is blocked by default at the account level; we can make an exception to it for a VPC if needed:
resource "aws_vpc_block_public_access_exclusion" "allow_public_access" {
  count                           = var.block_public_access ? 0 : 1
  vpc_id                          = aws_vpc.this.id
  internet_gateway_exclusion_mode = "allow-bidirectional"
}

module "private_subnets" {
  source             = "./subnets"
  name               = "private"
  vpc_id             = aws_vpc.this.id
  availability_zones = var.availability_zones
  force_cidr_ranges  = var.force_subnet_cidr_ranges
  width              = var.private_subnet_width
  offset             = 0
}

resource "aws_default_security_group" "default" {
  vpc_id  = aws_vpc.this.id
  ingress = null
  egress  = null
  tags = merge(
    {
      Name     = "${var.vpc_name}-default-sg"
      vpc_name = var.vpc_name
      default  = "true"
    },
    var.tags
  )
}

# Profile Association for VPC
resource "aws_route53profiles_association" "this" {
  count       = var.enable_dns_profile ? 1 : 0
  name        = "${var.vpc_name}-profile-association"
  profile_id  = var.profile_id
  resource_id = aws_vpc.this.id
}
