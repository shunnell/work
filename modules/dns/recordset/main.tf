locals {
  # Use short TTL; can be lengthened or made customizable if that causes cost issues:
  ttl = 60
}

resource "aws_route53_zone" "this" {
  name = var.domain
  dynamic "vpc" {
    for_each = var.vpc_associations
    content {
      vpc_id = vpc.value
    }
  }
  comment = "Cloud-City provisioned hosted zone: ${var.description}"
  tags    = var.tags
}

resource "aws_route53_record" "a_records" {
  for_each = var.a_records
  zone_id  = aws_route53_zone.this.zone_id               # Use the new hosted zone ID
  name     = "${each.key}.${aws_route53_zone.this.name}" # Adjust the record name as necessary
  type     = "A"
  ttl      = local.ttl
  records  = each.value
}

resource "aws_route53_record" "alias_records" {
  for_each = var.alias_records
  zone_id  = aws_route53_zone.this.zone_id               # Use the new hosted zone ID
  name     = "${each.key}.${aws_route53_zone.this.name}" # Adjust the record name as necessary
  type     = "A"
  # NB: TTL is not set here as the presence of an 'alias' block forces it to 60 by default:
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#alias-record
  alias {
    evaluate_target_health = each.value.evaluate_target_health
    name                   = each.value.name
    zone_id                = each.value.zone_id
  }
}

resource "aws_route53_record" "cname_records" {
  for_each = var.cname_records
  zone_id  = aws_route53_zone.this.zone_id               # Use the new hosted zone ID
  name     = "${each.key}.${aws_route53_zone.this.name}" # Adjust the record name as necessary
  type     = "CNAME"
  ttl      = local.ttl
  records  = [each.value]
}
