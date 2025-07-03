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
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment"></a> [comment](#input\_comment) | Comment for the hosted zone. | `string` | `null` | no |
| <a name="input_private_zone"></a> [private\_zone](#input\_private\_zone) | Create a private hosted zone if true, otherwise public. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the hosted zone. | `map(string)` | `{}` | no |
| <a name="input_vpc_ids"></a> [vpc\_ids](#input\_vpc\_ids) | List of VPC IDs to associate the private zone with. If empty or private\_zone=false, no associations are made. | `list(string)` | `[]` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The AWS region of the VPCs to associate (only used if private\_zone=true). | `string` | `""` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | The DNS name for the hosted zone (no trailing dot). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | List of NS records assigned by Route53. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The ID of the hosted zone. |
| <a name="output_zone_name"></a> [zone\_name](#output\_zone\_name) | The name of the zone. |
<!-- END_TF_DOCS -->