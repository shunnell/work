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
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tgw_routes"></a> [tgw\_routes](#input\_tgw\_routes) | Maps of maps of Transit Gateway routes | `map(any)` | `{}` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | ID of the Transit Gateway | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tgw_routes"></a> [tgw\_routes](#output\_tgw\_routes) | Map of TGW routes |
<!-- END_TF_DOCS -->