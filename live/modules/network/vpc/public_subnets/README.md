# `public_subnets`

This module creates subnets with associated EIPs and NAT gateways, as well as an internet gateway. However, it does **not** create explicit routes to the created NAT gateways or internet gateway; if that routing is desired, it should be added externally.

**Use immense care when instantiating this module.** Public subnets should be incredibly rare in BESPIN, and should only be present in exceptional testing circumstances or in the `network` account at the main network egress points for the platform.

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
| <a name="module_subnets"></a> [subnets](#module\_subnets) | ../subnets | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | See equivalently named parameter in 'subnets' module | `set(string)` | n/a | yes |
| <a name="input_force_cidr_ranges"></a> [force\_cidr\_ranges](#input\_force\_cidr\_ranges) | See equivalently named parameter in 'subnets' module | `map(string)` | `{}` | no |
| <a name="input_offset"></a> [offset](#input\_offset) | See equivalently named parameter in 'subnets' module | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | See equivalently named parameter in 'subnets' module | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | See equivalently named parameter in 'subnets' module | `string` | n/a | yes |
| <a name="input_width"></a> [width](#input\_width) | See equivalently named parameter in 'subnets' module | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Subnets created. Map of AZ name => {subnet\_id, route\_table\_id, cidr\_block, nat\_gateway\_id, eip\_id} |
<!-- END_TF_DOCS -->