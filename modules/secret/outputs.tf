output "secret_id" {
  description = "Secret ID."
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "Secret ARN."
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_id_version" {
  description = "A pipe delimited combination of secret ID and version ID."
  value       = aws_secretsmanager_secret_version.this.id
}
