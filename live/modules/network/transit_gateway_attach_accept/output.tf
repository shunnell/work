output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment_accepter.this.id
}

