output "arn" {
  value       = aws_kms_key.this.arn
  description = "ARN of the created key"
}

output "id" {
  value       = aws_kms_key.this.id
  description = "ID of the created key"
}

output "alias_name" {
  value       = aws_kms_alias.key_alias.name
  description = "Alias name of the created key"
}

output "alias_arn" {
  value       = aws_kms_alias.key_alias.arn
  description = "Alias ARN of the created key"
}