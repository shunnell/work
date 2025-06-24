output "bucket_website_endpoint" {
  description = "S3 website endpoint for the static site"
  value       = aws_s3_bucket.this.website_endpoint
}

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}
