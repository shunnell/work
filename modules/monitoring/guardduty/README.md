<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_association.guardduty_state_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association) | resource |
| [aws_ssm_document.ensure_guardduty_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_instances.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_instances.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_tag_key"></a> [eks\_tag\_key](#input\_eks\_tag\_key) | EC2 tag key used by EKS nodes | `string` | `"eks:cluster-name"` | no |
| <a name="input_ssm_document_name"></a> [ssm\_document\_name](#input\_ssm\_document\_name) | Name for the SSM document that enables the GuardDuty agent | `string` | `"EnableGuardDutyRuntimeAgent"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_target_count"></a> [ec2\_target\_count](#output\_ec2\_target\_count) | Count of EC2 instances managed by State Manager |
<!-- END_TF_DOCS -->