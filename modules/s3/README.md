```
███████╗██████╗     ██████╗ ██╗   ██╗ ██████╗██╗  ██╗███████╗████████╗
██╔════╝╚════██╗    ██╔══██╗██║   ██║██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝
███████╗ █████╔╝    ██████╔╝██║   ██║██║     █████╔╝ █████╗     ██║   
╚════██║ ╚═══██╗    ██╔══██╗██║   ██║██║     ██╔═██╗ ██╔══╝     ██║   
███████║██████╔╝    ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗   ██║   
╚══════╝╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝   
```
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_local_roles"></a> [local\_roles](#module\_local\_roles) | ../iam/local_role_data | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_object_lock_configuration.object_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_policy.main_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_acceleration"></a> [bucket\_acceleration](#input\_bucket\_acceleration) | Enable acceleration for the bucket | `bool` | `false` | no |
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | n/a | `string` | `null` | no |
| <a name="input_empty_bucket_when_deleted"></a> [empty\_bucket\_when\_deleted](#input\_empty\_bucket\_when\_deleted) | Whether or not to empty the bucket and delete all contained objects when it is deleted via Terraform/Terragrunt | `bool` | `false` | no |
| <a name="input_globally_unique_name"></a> [globally\_unique\_name](#input\_globally\_unique\_name) | GLOBALLY UNIQUE name of the S3 bucket. Must be unique across all customers of AWS (not just our accounts or regions: every AWS user in the entire world). Most cases should use 'name\_prefix' instead. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS Key ARN used to encrypt this bucket. Defaults to the account-wide default S3 encryption KMS key. | `string` | `"aws/s3"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix of the S3 bucket. | `string` | n/a | yes |
| <a name="input_object_lock"></a> [object\_lock](#input\_object\_lock) | Whether to enable Object Lock on the bucket | `bool` | `true` | no |
| <a name="input_policy_stanzas"></a> [policy\_stanzas](#input\_policy\_stanzas) | Stanzas to add to the bucket policy (in addition to default rules requiring HTTPS access and administration). By default a stanza applies to all objects in the bucket; specify 'object\_paths' to narrow that. | <pre>map(object({<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })), [])<br/>    actions      = set(string)<br/>    principals   = map(set(string))          # E.g. "AWS" = ["arn:aws:iam:foobar"]<br/>    object_paths = optional(set(string), []) # Paths within the bucket, e.g. ["/foo/*"]<br/>  }))</pre> | `{}` | no |
| <a name="input_record_history"></a> [record\_history](#input\_record\_history) | Whether to set bucket versioning and Object Lock on this bucket; Security Hub complains if you do not do this. If it is turned off for a bucket (e.g. for clients that don't support Object Lock headers), comment the invocation thoroughly as security scan findings will occur that need to be justified. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the bucket |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The name of the bucket |
<!-- END_TF_DOCS -->