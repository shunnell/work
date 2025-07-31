# `cloudwatch_log_shipping_destination/multiple`

This simple module instantiates multiple `cloudwatch_log_shipping_destination` instances according to passed-in data.

It is used for tenant baseline monitoring, which needs several near-identical log shipment streams be created in many places.
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose_destination"></a> [firehose\_destination](#module\_firehose\_destination) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_list_mapping"></a> [account\_list\_mapping](#input\_account\_list\_mapping) | pairs of account\_ids and account names to identify tenants | `map(string)` | `{}` | no |
| <a name="input_destination_names"></a> [destination\_names](#input\_destination\_names) | Vector of destination names, which can be any string | `set(string)` | n/a | yes |
| <a name="input_failed_shipments_cloudwatch_log_group_name"></a> [failed\_shipments\_cloudwatch\_log\_group\_name](#input\_failed\_shipments\_cloudwatch\_log\_group\_name) | See variable of the same name in cloudwatch\_log\_shipping\_destination | `string` | n/a | yes |
| <a name="input_failed_shipments_s3_bucket_arn"></a> [failed\_shipments\_s3\_bucket\_arn](#input\_failed\_shipments\_s3\_bucket\_arn) | See variable of the same name in cloudwatch\_log\_shipping\_destination | `string` | n/a | yes |
| <a name="input_log_sender_aws_organization_path"></a> [log\_sender\_aws\_organization\_path](#input\_log\_sender\_aws\_organization\_path) | See variable of the same name in cloudwatch\_log\_shipping\_destination | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the resource | `map(string)` | `{}` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_to_destination_arn"></a> [service\_to\_destination\_arn](#output\_service\_to\_destination\_arn) | n/a |
<!-- END_TF_DOCS -->