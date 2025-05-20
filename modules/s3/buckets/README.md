# S3 Buckets
Collection of related buckets, but different names.

# Terraform Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets_with_global_name"></a> [buckets\_with\_global\_name](#module\_buckets\_with\_global\_name) | ../ | n/a |
| <a name="module_buckets_with_prefix"></a> [buckets\_with\_prefix](#module\_buckets\_with\_prefix) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_acceleration"></a> [bucket\_acceleration](#input\_bucket\_acceleration) | Enable acceleration for the bucket | `bool` | `false` | no |
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | n/a | `string` | `null` | no |
| <a name="input_empty_bucket_when_deleted"></a> [empty\_bucket\_when\_deleted](#input\_empty\_bucket\_when\_deleted) | Whether or not to empty the bucket and delete all contained objects when it is deleted via Terraform/Terragrunt | `bool` | `false` | no |
| <a name="input_globally_unique_names"></a> [globally\_unique\_names](#input\_globally\_unique\_names) | GLOBALLY UNIQUE names of the S3 buckets. Must be unique across all customers of AWS (not just our accounts or regions: every AWS user in the entire world). Most cases should use 'name\_prefix' instead. | `set(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS Key ARN used to encrypt this bucket. Defaults to the account-wide default S3 encryption KMS key. | `string` | `"aws/s3"` | no |
| <a name="input_name_prefixes"></a> [name\_prefixes](#input\_name\_prefixes) | Name prefixes of the S3 buckets. | `set(string)` | `[]` | no |
| <a name="input_policy_stanzas"></a> [policy\_stanzas](#input\_policy\_stanzas) | Stanzas to add to the bucket policy (in addition to default rules requiring HTTPS access and administration). By default a stanza applies to all objects in the bucket; specify 'object\_paths' to narrow that. | <pre>map(object({<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })), [])<br/>    actions      = set(string)<br/>    principals   = map(set(string))          # E.g. "AWS" = ["arn:aws:iam:foobar"]<br/>    object_paths = optional(set(string), []) # Paths within the bucket, e.g. ["/foo/*"]<br/>  }))</pre> | `{}` | no |
| <a name="input_record_history"></a> [record\_history](#input\_record\_history) | See variable of same name in s3/variables.tf | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets"></a> [buckets](#output\_buckets) | The collection of buckets |
<!-- END_TF_DOCS -->