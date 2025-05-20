# `eventbridge_to_cloudwatch_logs`

This module takes a list of AWS services (e.g. `guardduty` or `codeartifact`) and captures all of each service's logs
via EventBridge, storing them to CloudWatch log groups (one per service) locally.

The capture policy used internally is a limited resource (only 10 can exist per account), so this module takes a list
of AWS service names rather than only taking one and having the module be instantiated multiple times.

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
| <a name="module_cwlg"></a> [cwlg](#module\_cwlg) | ../cloudwatch_log_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_resource_policy.cwlg_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_services"></a> [aws\_services](#input\_aws\_services) | List of names AWS service for which to capture EventBridge events in CloudWatch logs, not starting with 'aws.' Example: ['guardduty', 'codeartifact'] | `set(string)` | n/a | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | How long to retain EventBridge-captured logs in the local account. Defaulted to 1 (the minimum) since most EventBridge logs are immediately shipped to Splunk. | `number` | `1` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arns"></a> [cloudwatch\_log\_group\_arns](#output\_cloudwatch\_log\_group\_arns) | ARNs of the cloudwatch log groups that capture each AWS service. Map of service (from aws\_services) to ARN. |
<!-- END_TF_DOCS -->