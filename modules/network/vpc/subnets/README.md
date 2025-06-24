# `vpc/subnets`

This module declares a set of subnets for private.

**Note** that the `vpc` module instantiates this module to create a set of default private subnets for a VPC.

All subnets created by this module are placed in auto-generated CIDR ranges in the IP space of the VPC passed in `vpc_id`. That auto-CIDR-selection logic can be overridden via the `force_cidr_ranges` variable, but that should not ordinarily be used; it is intended only to support the `terraform import`ing of pre-existing subnets whose CIDR ranges do not match the assumptions made by this module.

Note well: **no routes are created by this module**. Instantiating this module alone will result in a set of subnets that can only be used for private, routing-between-each-other use. If routes into or out of these subnets are needed, they should be added by separate Terraform or Terragrunt code; think of this module as provisioning the virtual networking "hardware", onto which routes are later configured as an "overlay". We recommend using Terragrunt to define the routing overlay, as that tool makes the dependency on this module explicit.

All private subnets created by this module are tagged appropriately to allow EKS clusters to run load balancers in them using the Load Balancer Controller (see `eks/cluster/bootstrap` for more details).

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
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones in which this VPC will create subnets | `set(string)` | n/a | yes |
| <a name="input_force_cidr_ranges"></a> [force\_cidr\_ranges](#input\_force\_cidr\_ranges) | Should not normally be set. Overrides subnet-width-based selection of CIDR ranges for subnets. Map of AZ => CIDR. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_offset"></a> [offset](#input\_offset) | n/a | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | 'tier' in which subnets will be placed. Should not ordinarily be set. | `string` | `"private"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_width"></a> [width](#input\_width) | n/a | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Subnets created. Map of AZ name => {subnet\_id => id, route\_table\_id => id, cidr\_block => cidr} |
<!-- END_TF_DOCS -->