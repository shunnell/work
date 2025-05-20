output "tgw_routes" {
  description = "Map of TGW routes"
  value       = { for k, v in aws_ec2_transit_gateway_route.this : k => v.id }
}
