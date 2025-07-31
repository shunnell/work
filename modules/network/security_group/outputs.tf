output "id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

output "arn" {
  description = "ARN of the Security Group"
  value       = aws_security_group.this.arn
}
