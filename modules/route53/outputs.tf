output "hosted_zone_id" {
  description = "Hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "profile_id" {
  description = "Route53 Profile ID"
  value       = aws_route53profiles_profile.this.id
}
