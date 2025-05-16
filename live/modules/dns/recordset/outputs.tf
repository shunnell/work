output "hosted_zone_id" {
  value = aws_route53_zone.this.id
}

output "hosted_zone_arn" {
  value = aws_route53_zone.this.arn
}

output "a_records" {
  value = [for k in keys(var.a_records) : aws_route53_record.a_records[k].name]
}
