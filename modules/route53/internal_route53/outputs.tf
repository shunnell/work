output "zone_id" {
  description = "The ID of the hosted zone."
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "List of NS records assigned by Route53."
  value       = aws_route53_zone.this.name_servers
}

output "zone_name" {
  description = "The name of the zone."
  value       = aws_route53_zone.this.name
}
