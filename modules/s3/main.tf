resource "aws_s3_bucket" "this" {
  bucket        = var.globally_unique_name
  bucket_prefix = var.name_prefix
  tags          = var.tags
  force_destroy = var.empty_bucket_when_deleted
}

resource "aws_s3_bucket_acl" "this" {
  count  = var.bucket_acl == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
  acl    = var.bucket_acl
}

resource "aws_s3_bucket_accelerate_configuration" "this" {
  count  = var.bucket_acceleration ? 1 : 0
  bucket = aws_s3_bucket.this.id
  status = "Enabled"
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.record_history ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Security scanners want Object Lock configured on all S3 buckets, so we do so with some basic, flexible settings:
resource "aws_s3_bucket_object_lock_configuration" "object_lock" {
  count      = var.object_lock ? 1 : 0
  bucket     = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket_versioning.this]
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn == "aws/s3" ? null : var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    id     = "default"
    status = "Enabled"

    filter {
      prefix = "*"
    }

    # Enable a default NIST-800-53-compliant lifecycle policy: move to infrequent access after 30d and glacier after 60.
    # For old versions of objects, move them to glacier as soon as they get stale and delete them after 90d.
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    noncurrent_version_transition {
      noncurrent_days = 1
      storage_class   = "GLACIER"
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
