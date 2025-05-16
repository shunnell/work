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
| [aws_route53_record.a_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.alias_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cname_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_a_records"></a> [a\_records](#input\_a\_records) | Basic, non-alias 'A' records to be created in this recordset. Keys are hostnames (without the domain), values are lists of IP addresses (to create basic A records) or hostnames (to create alias records). | `map(list(string))` | `{}` | no |
| <a name="input_alias_records"></a> [alias\_records](#input\_alias\_records) | Alias 'A' records to be created in this recordset. Keys are hostnames (without the domain), values are maps containing zone\_id, name, and evaluate\_target\_health | <pre>map(object({<br/>    zone_id                = string<br/>    name                   = string<br/>    evaluate_target_health = optional(string, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_cname_records"></a> [cname\_records](#input\_cname\_records) | 'CNAME' records to be created in this recordset. Keys are hostnames (without the domain), values are other DNS locations. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description of this recordset and its hosted zone | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain of this recordset. A hostname of foo.bar.baz has a domain of 'baz'. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_associations"></a> [vpc\_associations](#input\_vpc\_associations) | List of VPCs to which to provide private DNS for this recordset. The FIRST item in this list will be used as the primary VPC/owner VPC of the created hosted zone. If 'null', a public, internet-available hosted zone will be created. Set this to 'null' with extreme care and prior approval from platform team lead engineering. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_a_records"></a> [a\_records](#output\_a\_records) | n/a |
| <a name="output_hosted_zone_arn"></a> [hosted\_zone\_arn](#output\_hosted\_zone\_arn) | n/a |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | n/a |
<!-- END_TF_DOCS -->