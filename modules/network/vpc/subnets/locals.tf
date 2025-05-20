data "aws_region" "current" {}
data "aws_vpc" "vpc" {
  id = var.vpc_id
}
locals {
  # Terraform hilariously doesn't have a function to convert a character to an ASCII code int, so we do it ourselves.
  # AWS has never gotten even close to 'z', and a billion billion lines of code in the world depend on AZs being the
  # region name followed by a single letter, so this should be safe.
  alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  # The below code places subnets in CIDR blocks per-AZ. Be very careful if you decide to change it.
  # Specifically, this encodes the convention that a subnet's CIDR range will be a "slice" of the VPC's CIDR range
  # that corresponds to the *name* of the AZ in which that subnet is placed. It is important that we base off of the
  # AZ name as a stable identifier rather than its position in the 'availability_zones' variable: if we based it off
  # of the variable alone, a change from 'availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]'
  # to '["us-east-1a", "us-east-1c", "us-east-1d"]' would result in full subnet replacement of the 1c and 1d subnets,
  # not good.
  az_to_cidr = length(var.force_cidr_ranges) > 0 ? var.force_cidr_ranges : {
    for az in var.availability_zones : az => cidrsubnet(
      data.aws_vpc.vpc.cidr_block,
      var.width,
      # Grab the last letter of the AZ, e.g. 'e' from 'us-east-1e':
      var.offset + index(local.alphabet, substr(az, -1, -1))
    )
  }
  vpc_name = data.aws_vpc.vpc.tags.Name
  tags = merge(var.tags, {
    Tier     = title(var.tier)
    vpc_name = local.vpc_name
  })
}
