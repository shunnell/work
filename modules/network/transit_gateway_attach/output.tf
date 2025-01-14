output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.this.id
}

output "transit_gateway_route_table_arn" {
  description = "ARN of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.this.arn
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway Attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}


