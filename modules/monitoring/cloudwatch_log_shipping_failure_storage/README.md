<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | ../cloudwatch_log_group | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../s3 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Globally unique name of log group and S3 bucket | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_failed_shipments_cloudwatch_log_group_name"></a> [failed\_shipments\_cloudwatch\_log\_group\_name](#output\_failed\_shipments\_cloudwatch\_log\_group\_name) | n/a |
| <a name="output_failed_shipments_s3_bucket_arn"></a> [failed\_shipments\_s3\_bucket\_arn](#output\_failed\_shipments\_s3\_bucket\_arn) | n/a |
<!-- END_TF_DOCS -->