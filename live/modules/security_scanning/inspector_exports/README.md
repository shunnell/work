# `inspector_exports`

This module configures the invoking AWS account with appropriate S3 and KMS entities to use the AWS Inspector web UI
to export findings. 

It sets up the permissions and objects required for exports per the [AWS documentation](https://docs.aws.amazon.com/inspector/latest/user/findings-managing-exporting-reports.html).

After applying this module, request an export in the AWS Inspector UI using the KMS key with "inspector-exports" in its 
name, targeting the S3 bucket with "inspector-exports" in its name.

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
| <a name="module_exports_bucket"></a> [exports\_bucket](#module\_exports\_bucket) | ../../s3 | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | ../../kms/key | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_export_bucket_arn"></a> [export\_bucket\_arn](#output\_export\_bucket\_arn) | n/a |
| <a name="output_export_kms_key_arn"></a> [export\_kms\_key\_arn](#output\_export\_kms\_key\_arn) | n/a |
<!-- END_TF_DOCS -->