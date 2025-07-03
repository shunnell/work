module "website_bucket" {
  source                    = "../../s3"
  name_prefix               = var.name_prefix
  globally_unique_name      = null
  record_history            = false
  object_lock               = false
  empty_bucket_when_deleted = false
  policy_stanzas = {
    PublicRead = {
      actions      = ["s3:GetObject"]
      principals   = { AWS = ["*"] }
      object_paths = []
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = module.website_bucket.bucket_id
  index_document {
    suffix = var.default_root_object
  }
  error_document {
    key = var.error_document
  }
}

data "aws_region" "current" {}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name_prefix}-static-site"
  default_root_object = var.default_root_object

  origin {
    domain_name = "${module.website_bucket.bucket_id}.s3-website-${data.aws_region.current.name}.amazonaws.com"
    origin_id   = var.name_prefix

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = var.aliases

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.name_prefix

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"
  tags        = var.tags

  dynamic "logging_config" {
    for_each = var.logging_bucket != "" ? [1] : []
    content {
      bucket          = var.logging_bucket
      prefix          = var.logging_prefix
      include_cookies = var.logging_include_cookies
    }
  }
}
