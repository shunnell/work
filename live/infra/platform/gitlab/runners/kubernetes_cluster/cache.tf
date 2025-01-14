## Set up Global cache
resource "aws_s3_bucket" "gitlab_cache_bucket" {
  bucket = "dos-gitlab-central-runner-cache"
}

resource "aws_s3_bucket_versioning" "gitlab_cache_versioning" {
  bucket = aws_s3_bucket.gitlab_cache_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_public_access_block" "gitlab_cache_public_access" {
  bucket = aws_s3_bucket.gitlab_cache_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
