output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.this.id
}

output "transit_gateway_route_table_arn" {
  description = "ARN of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.this.arn
}
