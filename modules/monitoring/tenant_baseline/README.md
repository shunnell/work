# Tenant monitoring baseline

This module contains a "preset" list of monitoring settings that all accounts in Cloud City should have.

This module should be present in all accounts, and is used to set up the uniform standard of log data transfer from an AWS
account to the central "log management" AWS account.

Additional logs can be shared/shipped in addition to the ones provided here, on a per-account basis; this code represents things that should always be connected everywhere. Specifically, it includes:
- Dependencies on the "other side" of the log shipping/sharing: log-management account entities for receiving data.
- By-default OAM sharing of all metric and log group data for UI browsing and read in the log-archive account (but
  not tailing or subscription to Firehose there, unfortunately; OAM is limited at the time of this writing).
- Gathering of all GuardDuty data via EventBridge into an account-local CloudWatch log group.
- Shipping of that GuardDuty log group to a shared Firehose which receives all accounts' GuardDuty data.
- Gathering of all AWS Config data via EventBridge into an account-local CloudWatch log group.
- Shipping of that AWS Config log group to a shared Firehose which receives all accounts' AWS Config data.

This module declares very few resources locally, instead invoking other modules in this repo (each of which can also be invoked
on their own to accomplish other things; this is by no means a sole entry point into monitoring).

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventbridge_to_cloudwatch"></a> [eventbridge\_to\_cloudwatch](#module\_eventbridge\_to\_cloudwatch) | ../eventbridge_to_cloudwatch_logs | n/a |
| <a name="module_logs_to_firehose"></a> [logs\_to\_firehose](#module\_logs\_to\_firehose) | ../cloudwatch_log_shipping_source | n/a |
| <a name="module_oam_link"></a> [oam\_link](#module\_oam\_link) | ../cloudwatch_sharing_source | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventbridge_service_name_to_destination_arn"></a> [eventbridge\_service\_name\_to\_destination\_arn](#input\_eventbridge\_service\_name\_to\_destination\_arn) | Map of eventbridge service names (without 'aws.' prefix) to log shipment Cloudwatch::Logs::Destination ARNs | `map(string)` | n/a | yes |
| <a name="input_oam_shared_resource_types"></a> [oam\_shared\_resource\_types](#input\_oam\_shared\_resource\_types) | List of AWS OAM-supported resource types (e.g. AWS::Logs::LogGroup) to share with the sink | `list(string)` | <pre>[<br/>  "AWS::Logs::LogGroup",<br/>  "AWS::CloudWatch::Metric"<br/>]</pre> | no |
| <a name="input_oam_sink_id"></a> [oam\_sink\_id](#input\_oam\_sink\_id) | ARN of the CloudWatch OAM::Sink object to share data with (aka the receiver) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_group_arns"></a> [log\_group\_arns](#output\_log\_group\_arns) | ARNs of the cloudwatch log groups that capture each AWS service from EventBridge. Map of service name to ARN. |
<!-- END_TF_DOCS -->