module "buckets_with_prefix" {
  source = "../"

  for_each    = var.name_prefixes
  name_prefix = each.value

  record_history            = var.record_history
  empty_bucket_when_deleted = var.empty_bucket_when_deleted
  bucket_acceleration       = var.bucket_acceleration
  bucket_acl                = var.bucket_acl
  kms_key_arn               = var.kms_key_arn
  policy_stanzas            = var.policy_stanzas
  tags                      = var.tags
}

module "buckets_with_global_name" {
  source = "../"

  for_each                  = var.globally_unique_names
  empty_bucket_when_deleted = var.empty_bucket_when_deleted
  name_prefix               = null

  record_history       = var.record_history
  globally_unique_name = each.value
  bucket_acceleration  = var.bucket_acceleration
  bucket_acl           = var.bucket_acl
  kms_key_arn          = var.kms_key_arn
  policy_stanzas       = var.policy_stanzas
  tags                 = var.tags
}
