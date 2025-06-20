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
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.amazon_linux2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_instances.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_guardduty"></a> [enable\_guardduty](#input\_enable\_guardduty) | Whether to install and enable the GuardDuty runtime agent. | `bool` | `true` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of **new** EC2 instances you want to add.<br/>Terraform will look up how many EC2s already exist (running or stopped) with tag:Project = instance\_name\_prefix, <br/>then create exactly `instance_count` new ones on top of that. | `number` | n/a | yes |
| <a name="input_instance_name_prefix"></a> [instance\_name\_prefix](#input\_instance\_name\_prefix) | Prefix to use for each EC2’s Name tag and also the Project tag filter. Example: "testing-ec2". | `string` | n/a | yes |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | IAM Instance Profile name to attach for SSM access. If empty, no profile is attached. | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type (e.g. "t3.medium"). | `string` | n/a | yes |
| <a name="input_name_tag"></a> [name\_tag](#input\_name\_tag) | n/a | `string` | `"Enabled"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID in which to launch the EC2s. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to each EC2. | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs to attach to each EC2. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | The GuardDuty detector ID (or null if enable\_guardduty = false). |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | List of all EC2 instance IDs (one per for\_each element). |
<!-- END_TF_DOCS -->