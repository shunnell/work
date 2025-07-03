locals {
  additional_vpc_ids = length(var.vpc_ids) > 1
    ? slice(var.vpc_ids, 1, length(var.vpc_ids))
    : []
}

resource "aws_route53_zone" "this" {
  name = var.zone_name

  vpc {
    vpc_id     = var.vpc_ids[0]
    vpc_region = var.vpc_region
  }

  comment = var.comment
  tags    = var.tags
}

resource "aws_route53_zone_association" "additional" {
  for_each   = toset(local.additional_vpc_ids)
  zone_id    = aws_route53_zone.this.zone_id
  vpc_id     = each.value
  vpc_region = var.vpc_region
}
