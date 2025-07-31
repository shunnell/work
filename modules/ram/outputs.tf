output "resource_share_arn" {
  description = "ARN of the RAM resource share"
  value       = aws_ram_resource_share.this.arn
}

output "resource_share_id" {
  description = "ID of the RAM resource share"
  value       = aws_ram_resource_share.this.id
}
