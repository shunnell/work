output "cloudwatch_destination_arn" {
  description = "ARN of the CloudWatch::Destination object that logs should be shipped to from other accounts"
  value       = aws_cloudwatch_log_destination.log_destination.arn
}