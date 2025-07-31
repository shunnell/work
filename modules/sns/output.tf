output "arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}