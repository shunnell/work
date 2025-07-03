locals {
  additional_vpc_ids = (
    var.private_zone && length(var.vpc_ids) > 1
    ? slice(var.vpc_ids, 1, length(var.vpc_ids))
    : []
  )
}

# Create the zone (public or private with the first VPC)
resource "aws_route53_zone" "this" {
  name = var.zone_name

  dynamic "vpc" {
    for_each = var.private_zone && length(var.vpc_ids) > 0 ? [var.vpc_ids[0]] : []
    content {
      vpc_id     = vpc.value
      vpc_region = var.vpc_region
    }
  }

  comment = var.comment
  tags    = var.tags
}

# If more than one VPC, associate the rest
resource "aws_route53_zone_association" "additional" {
  for_each   = toset(local.additional_vpc_ids)
  zone_id    = aws_route53_zone.this.zone_id
  vpc_id     = each.value
  vpc_region = var.vpc_region
}

