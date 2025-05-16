variable "bucket_id" {
  description = "Name/ID of bucket to put item in"
  type        = string
}

variable "tags" {
  description = "AWS tags to apply to object"
  type        = map(string)
  default     = {}
}

locals {
  files = [
    "EKS-Security-BestPractices.yaml",
    "NIST-800-53-rev5.yaml",
    "Operational-Best-Practices-for-FedRAMP-High.yaml",
    "Operational-Best-Practices-for-FedRAMP.yaml"
  ]
}

resource "aws_s3_object" "aws_conformance_packs" {
  count = length(local.files)

  bucket = var.bucket_id
  key    = local.files[count.index]
  source = local.files[count.index]
  tags   = var.tags
  # etag   = filemd5(local.files[count.index]) # different every plan
}
