output "route_ids" {
  description = "Map of route IDs"
  value       = { for k, v in aws_route.this : k => v.id }
} 