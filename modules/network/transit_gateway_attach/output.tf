output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway Attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

