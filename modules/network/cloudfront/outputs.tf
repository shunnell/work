output "bucket_id" {
  description = "The name of the website S3 bucket"
  value       = module.website_bucket.bucket_id
}

output "bucket_website_domain" {
  description = "The website endpoint domain"
  value       = "${module.website_bucket.bucket_id}.s3-website-${data.aws_region.current.name}.amazonaws.com"
}

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}
