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
| [aws_backup_plan.eks_ebs_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.eks_ebs_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_iam_role.existing_backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_plan_name"></a> [backup\_plan\_name](#input\_backup\_plan\_name) | Name of the AWS Backup plan | `string` | n/a | yes |
| <a name="input_backup_rule_name"></a> [backup\_rule\_name](#input\_backup\_rule\_name) | Name of the backup rule | `string` | n/a | yes |
| <a name="input_completion_window"></a> [completion\_window](#input\_completion\_window) | Completion window time in minutes | `number` | n/a | yes |
| <a name="input_delete_after_days"></a> [delete\_after\_days](#input\_delete\_after\_days) | Number of days after which to delete the recovery point | `number` | n/a | yes |
| <a name="input_existing_backup_role_name"></a> [existing\_backup\_role\_name](#input\_existing\_backup\_role\_name) | Existing IAM role to use for backup selection | `string` | n/a | yes |
| <a name="input_recovery_point_tags"></a> [recovery\_point\_tags](#input\_recovery\_point\_tags) | Tags to apply to AWS Backup recovery points | `map(string)` | n/a | yes |
| <a name="input_schedule_frequency"></a> [schedule\_frequency](#input\_schedule\_frequency) | Backup frequency: one of daily, hourly, weekly, monthly | `string` | n/a | yes |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | Map of key-value pairs used for selecting resources to back up | `map(string)` | n/a | yes |
| <a name="input_start_window"></a> [start\_window](#input\_start\_window) | Start window time in minutes | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_id"></a> [backup\_plan\_id](#output\_backup\_plan\_id) | The ID of the AWS Backup plan created for EKS EBS volumes |
| <a name="output_backup_role_arn"></a> [backup\_role\_arn](#output\_backup\_role\_arn) | The ARN of the existing IAM role used for AWS Backup operations |
| <a name="output_backup_selection_id"></a> [backup\_selection\_id](#output\_backup\_selection\_id) | The ID of the AWS Backup selection associated with the backup plan |
<!-- END_TF_DOCS -->