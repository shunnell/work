output "gateway_endpoint_ids" {
  description = "Map of gateway endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.this_gateway : k => v.id }
}

output "interface_endpoint_ids" {
  description = "Map of interface endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.this_interface : k => v.id }
}

output "interface_endpoint_dns_entries" {
  description = "DNS entries for interface endpoints"
  value       = { for k, v in aws_vpc_endpoint.this_interface : k => v.dns_entry }
}
