<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose_role"></a> [firehose\_role](#module\_firehose\_role) | ../../iam/role | n/a |
| <a name="module_lambda_role"></a> [lambda\_role](#module\_lambda\_role) | ../../iam/role | n/a |
| <a name="module_write_to_firehose_role"></a> [write\_to\_firehose\_role](#module\_write\_to\_firehose\_role) | ../../iam/role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_destination.log_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_destination) | resource |
| [aws_cloudwatch_log_destination_policy.destination_cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_destination_policy) | resource |
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.firehose_shipment_failure_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_policy.firehose_execution_and_processing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.write_to_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.firehose_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_lambda_function.lambda_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [archive_file.transformer_lambda_script](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_kms_key.aws_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_name"></a> [destination\_name](#input\_destination\_name) | Name of this destination (e.g. 'CloudWatch' or 'GuardDuty'). Destinations are heavy-weight and should be shared where appropriate in order to maximize shipping efficiency and reduce infrastructure complexity. | `string` | n/a | yes |
| <a name="input_failed_shipments_cloudwatch_log_group_name"></a> [failed\_shipments\_cloudwatch\_log\_group\_name](#input\_failed\_shipments\_cloudwatch\_log\_group\_name) | Name of a CloudWatch log group to which log shipment failure error information will be written by Firehose (transformation Lambda invocation failures will be written to a separate log group) | `string` | n/a | yes |
| <a name="input_failed_shipments_s3_bucket_arn"></a> [failed\_shipments\_s3\_bucket\_arn](#input\_failed\_shipments\_s3\_bucket\_arn) | ARN of a bucket which will store failed log shipments. Within this bucket, failed shipments will be stored under akey corresponding to destination\_name. | `string` | n/a | yes |
| <a name="input_log_sender_aws_organization_path"></a> [log\_sender\_aws\_organization\_path](#input\_log\_sender\_aws\_organization\_path) | ID of the AWS Organization or subpath within an Organization that should be permitted to send logs via this module's Firehose from other AWS accounts | `string` | n/a | yes |
| <a name="input_log_sourcetype"></a> [log\_sourcetype](#input\_log\_sourcetype) | Type of cloudwatch log (e.g 'cloudwatch', 'cloudtrail') to help label the sourcetype appropriately | `string` | `"aws:cloudwatch"` | no |
| <a name="input_shipment_buffering_size"></a> [shipment\_buffering\_size](#input\_shipment\_buffering\_size) | How many megabytes of logs to buffer before sending a shipment to Splunk | `number` | `1` | no |
| <a name="input_shipment_buffering_time"></a> [shipment\_buffering\_time](#input\_shipment\_buffering\_time) | How many seconds to buffer logs in BESPIN before shipping them | `number` | `60` | no |
| <a name="input_shipment_retry_duration"></a> [shipment\_retry\_duration](#input\_shipment\_retry\_duration) | How many seconds to wait before retrying a failed shipment | `number` | `10` | no |
| <a name="input_splunk_acknowledgement_timeout"></a> [splunk\_acknowledgement\_timeout](#input\_splunk\_acknowledgement\_timeout) | Number of seconds to wait for Splunk to acknowledge a log shipment before considering it failed (assuming that the splunk HEC ingester is configured to send acknowledgements) | `number` | `180` | no |
| <a name="input_splunk_hec_token"></a> [splunk\_hec\_token](#input\_splunk\_hec\_token) | String token to be used when identifying this log stream to Splunk | `string` | `"419b5b09-db88-48a0-bd1b-21ab330c0b0d"` | no |
| <a name="input_splunk_uri"></a> [splunk\_uri](#input\_splunk\_uri) | HTTP/S URI of the Splunk HEC destination to be used | `string` | `"https://casi.state.gov:8088"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_destination_arn"></a> [cloudwatch\_destination\_arn](#output\_cloudwatch\_destination\_arn) | ARN of the CloudWatch::Destination object that logs should be shipped to from other accounts |
<!-- END_TF_DOCS -->