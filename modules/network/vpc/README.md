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
| <a name="module_endpoint_sg"></a> [endpoint\_sg](#module\_endpoint\_sg) | ../security_group | n/a |
| <a name="module_flow_logs_group"></a> [flow\_logs\_group](#module\_flow\_logs\_group) | ../../monitoring/cloudwatch_log_group | n/a |
| <a name="module_flow_logs_role"></a> [flow\_logs\_role](#module\_flow\_logs\_role) | ../../iam/role | n/a |
| <a name="module_private_subnets"></a> [private\_subnets](#module\_private\_subnets) | ./subnets | n/a |
| <a name="module_public_subnets"></a> [public\_subnets](#module\_public\_subnets) | ./public_subnets | n/a |
| <a name="module_ship_logs_to_splunk"></a> [ship\_logs\_to\_splunk](#module\_ship\_logs\_to\_splunk) | ../../monitoring/cloudwatch_log_shipping_source | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_route53profiles_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_association) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_block_public_access_exclusion.allow_public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_block_public_access_exclusion) | resource |
| [aws_vpc_endpoint.gateway_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones in which this VPC will create subnets | `set(string)` | n/a | yes |
| <a name="input_block_public_access"></a> [block\_public\_access](#input\_block\_public\_access) | Whether to block public network access to/from this VPC. Should be 'true' in almost all cases | `bool` | `true` | no |
| <a name="input_create_public_subnets"></a> [create\_public\_subnets](#input\_create\_public\_subnets) | Only set to true for ALB ingress VPCs | `bool` | `false` | no |
| <a name="input_custom_cidr_range"></a> [custom\_cidr\_range](#input\_custom\_cidr\_range) | Custom CIDR range for the VPC endpoints security group rule used for shared services vpc | `string` | `null` | no |
| <a name="input_enable_dns"></a> [enable\_dns](#input\_enable\_dns) | Enable DNS in VPC | `bool` | `true` | no |
| <a name="input_enable_dns_profile"></a> [enable\_dns\_profile](#input\_enable\_dns\_profile) | Enable DNS profile | `bool` | `true` | no |
| <a name="input_force_subnet_cidr_ranges"></a> [force\_subnet\_cidr\_ranges](#input\_force\_subnet\_cidr\_ranges) | Should not normally be set. Overrides subnet-width-based selection of CIDR ranges for subnets. Map of AZ => CIDR. | `map(string)` | `{}` | no |
| <a name="input_gateway_endpoints"></a> [gateway\_endpoints](#input\_gateway\_endpoints) | Gateway endpoints for AWS services | `set(string)` | <pre>[<br/>  "s3"<br/>]</pre> | no |
| <a name="input_interface_endpoints"></a> [interface\_endpoints](#input\_interface\_endpoints) | Interface endpoints for AWS services whose endpoints are not created by the default compliance config in this module | `set(string)` | <pre>[<br/>  "ec2",<br/>  "ec2messages",<br/>  "ecr.api",<br/>  "ecr.dkr",<br/>  "eks",<br/>  "elasticloadbalancing",<br/>  "guardduty-data",<br/>  "inspector-scan",<br/>  "inspector2",<br/>  "kms",<br/>  "logs",<br/>  "rds",<br/>  "secretsmanager",<br/>  "ssm-incidents",<br/>  "ssm",<br/>  "ssmmessages",<br/>  "sts"<br/>]</pre> | no |
| <a name="input_log_shipping_destination_arn"></a> [log\_shipping\_destination\_arn](#input\_log\_shipping\_destination\_arn) | Cloudwatch::Logs::Destination ARN to ship internally-generated flow logs from CloudWatch logs to Splunk (ARN supplied via the monitoring/cloudwatch\_log\_shipping\_destination module) | `string` | n/a | yes |
| <a name="input_private_subnet_width"></a> [private\_subnet\_width](#input\_private\_subnet\_width) | Width in bits that each subnet will claim in IP addressing space. If the VPC CIDR is a /16, a width of 4 means that subnets will be placed in /20 ranges within that CIDR. | `number` | `4` | no |
| <a name="input_profile_id"></a> [profile\_id](#input\_profile\_id) | Route53 Profiles ID | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_security_group_id"></a> [endpoint\_security\_group\_id](#output\_endpoint\_security\_group\_id) | ID of the security group containing all VPC endpoints |
| <a name="output_gateway_endpoint_ids"></a> [gateway\_endpoint\_ids](#output\_gateway\_endpoint\_ids) | Map of gateway endpoint IDs |
| <a name="output_interface_endpoint_ids"></a> [interface\_endpoint\_ids](#output\_interface\_endpoint\_ids) | Map of interface endpoint IDs |
| <a name="output_private_subnets_by_az"></a> [private\_subnets\_by\_az](#output\_private\_subnets\_by\_az) | Subnets created. Map of AZ name => {subnet\_id => id, route\_table\_id => id, cidr\_block => cidr} |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | IDs of public subnets (empty if none created) |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC |
<!-- END_TF_DOCS -->