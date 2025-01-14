output "db_instance_endpoint" {
  description = "The connection endpoint for the DB instance."
  value       = aws_db_instance.example.endpoint
}

output "db_instance_id" {
  description = "The ID of the DB instance."
  value       = aws_db_instance.example.id
}