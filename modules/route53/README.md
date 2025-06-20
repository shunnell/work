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
| [aws_ram_principal_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53profiles_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_association) | resource |
| [aws_route53profiles_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_profile) | resource |
| [aws_route53profiles_resource_association.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_resource_association) | resource |
| [aws_route53profiles_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_resource_association) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain name for the hosted zone | `string` | n/a | yes |
| <a name="input_interface_endpoints_ids"></a> [interface\_endpoints\_ids](#input\_interface\_endpoints\_ids) | The interface endpoints to associate with the hosted zone | <pre>map(object({<br/>    arn = string<br/>    id  = string<br/>  }))</pre> | `{}` | no |
| <a name="input_short_name"></a> [short\_name](#input\_short\_name) | The short name for the hosted zone | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags for the hosted zone | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to associate with the hosted zone | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC to associate with the hosted zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | Hosted zone ID |
| <a name="output_profile_id"></a> [profile\_id](#output\_profile\_id) | Route53 Profile ID |
<!-- END_TF_DOCS -->