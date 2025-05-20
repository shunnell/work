# Common Account Configuration
Common configuration that all accounts should have.

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
| <a name="module_access_analyzer"></a> [access\_analyzer](#module\_access\_analyzer) | ../../iam/tenant_baseline/access-analyzer | n/a |
| <a name="module_dummy_sandbox_bounded_role"></a> [dummy\_sandbox\_bounded\_role](#module\_dummy\_sandbox\_bounded\_role) | ../../iam/role | n/a |
| <a name="module_iam_fragments"></a> [iam\_fragments](#module\_iam\_fragments) | ../../iam/fragments | n/a |
| <a name="module_inspector_exports"></a> [inspector\_exports](#module\_inspector\_exports) | ../../security_scanning/inspector_exports | n/a |
| <a name="module_sandbox_permissions_boundary"></a> [sandbox\_permissions\_boundary](#module\_sandbox\_permissions\_boundary) | ../../iam/policy | n/a |
| <a name="module_support_access_role"></a> [support\_access\_role](#module\_support\_access\_role) | ../../iam/role | n/a |
| <a name="module_tenant_baseline"></a> [tenant\_baseline](#module\_tenant\_baseline) | ../../monitoring/tenant_baseline | n/a |
| <a name="module_wiz"></a> [wiz](#module\_wiz) | ../../wiz | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_account_alternate_contact.billing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/account_alternate_contact) | resource |
| [aws_account_alternate_contact.security](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/account_alternate_contact) | resource |
| [aws_account_primary_contact.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/account_primary_contact) | resource |
| [aws_athena_workgroup.default_workgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_config_conformance_pack.eks-security-bestpractices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_config_conformance_pack.nist_800_53_rev5](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_config_conformance_pack.operational_for_fedramp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_config_conformance_pack.operational_for_fedramp_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_ebs_encryption_by_default.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.security_hub_compliance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_macie2_account.macie](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_account) | resource |
| [aws_servicequotas_service_quota.quotas](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicequotas_service_quota) | resource |
| [aws_servicequotas_service_quota.quotas_requiring_support_approval](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicequotas_service_quota) | resource |
| [aws_vpc_block_public_access_options.block_public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_block_public_access_options) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sandbox_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_servicequotas_service_quota.quotas_by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicequotas_service_quota) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventbridge_service_name_to_destination_arn"></a> [eventbridge\_service\_name\_to\_destination\_arn](#input\_eventbridge\_service\_name\_to\_destination\_arn) | Map of eventbridge service names (without 'aws.' prefix) to log shipment Cloudwatch::Logs::Destination ARNs | `map(string)` | n/a | yes |
| <a name="input_oam_shared_resource_types"></a> [oam\_shared\_resource\_types](#input\_oam\_shared\_resource\_types) | List of AWS OAM-supported resource types (e.g. AWS::Logs::LogGroup) to share with the sink | `list(string)` | <pre>[<br/>  "AWS::Logs::LogGroup",<br/>  "AWS::CloudWatch::Metric"<br/>]</pre> | no |
| <a name="input_oam_sink_id"></a> [oam\_sink\_id](#input\_oam\_sink\_id) | ARN of the CloudWatch OAM::Sink object to share data with (aka the receiver) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_quotas"></a> [quotas](#output\_quotas) | n/a |
| <a name="output_wiz_role_arn"></a> [wiz\_role\_arn](#output\_wiz\_role\_arn) | n/a |
| <a name="output_wiz_user_arn"></a> [wiz\_user\_arn](#output\_wiz\_user\_arn) | n/a |
<!-- END_TF_DOCS -->