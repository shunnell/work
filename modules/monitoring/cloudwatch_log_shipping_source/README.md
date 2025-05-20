# `cloudwatch_log_shipping_source`

This module configures a "source" for log shipping. Given a CloudWatch::Logs::Destination ARN (of the sort provided by the `cloudwatch_log_shipping_destination` module) and a CloudWatch::Logs::Group ARN, the logs in the log group are forwarded to the specified destination.

## Additional resources:
- https://confluence.fan.gov/x/iuLAHQ
- https://confluence.fan.gov/x/Acd_Hg
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-logs-destination.html
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_destination

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cwlg_subscription_filter_role"></a> [cwlg\_subscription\_filter\_role](#module\_cwlg\_subscription\_filter\_role) | ../../iam/role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_subscription_filter.subscribe_single_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.cwlg_subscription_write_allowlist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_arn"></a> [destination\_arn](#input\_destination\_arn) | ARN of the CloudWatch destination resource that will ship selected logs. Can be an account-local Lambda or Firehose or Kinesis stream, or a local or remote CloudWatch log destination. | `string` | n/a | yes |
| <a name="input_log_group_arns"></a> [log\_group\_arns](#input\_log\_group\_arns) | List of CloudWatch log group ARNs to ship to the Firehose specified in destination\_arn. ARNs may optionally end with ':*'; this does not affect internal operations. The ':*' suffix does not imply that this variable accepts log group patterns, however; only single ARNs may be specified. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->