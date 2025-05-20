output "export_bucket_arn" {
  value = module.exports_bucket.bucket_arn
}

output "export_kms_key_arn" {
  value = module.kms_key.arn
}
