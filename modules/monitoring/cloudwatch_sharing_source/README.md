# `cloudwatch_sharing_source`

This module provides two abilities: 
1. It enables an entire AWS account as an [OAM ("Cross-account observability access manager")](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Unified-Cross-Account.html)
2. It (optionally by default) disables the legacy (deprecated in favor of OAM) AWS CloudWatch sharing mechanism called ["Cross-Account Cross-Region Sharing"](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html)
source for specified CloudWatch entity types (e.g. log groups).

This enables those CloudWatch resources to be use from a separate AWS logging account.

See the `description` attributes of input and output data types for usage information.

# Additional resources:

- https://github.com/aws-samples/cloudwatch-obervability-access-manager-terraform
- https://gds.blog.gov.uk/2023/07/26/enabling-aws-cross-account-monitoring-using-terraform/
- https://repost.aws/questions/QUIMVcoQbaSYuDg5YQ9RbnwQ/cross-account-cross-region-in-cloudwatch-for-specific-log-group

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
| <a name="module_cacr_role"></a> [cacr\_role](#module\_cacr\_role) | ../../iam/role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_oam_link.link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/oam_link) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_shared_resource_types"></a> [shared\_resource\_types](#input\_shared\_resource\_types) | List of AWS OAM-supported resource types (e.g. AWS::Logs::LogGroup) to share with the sink | `list(string)` | n/a | yes |
| <a name="input_sink_id"></a> [sink\_id](#input\_sink\_id) | ARN of the CloudWatch OAM::Sink object to share data with (aka the receiver) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->