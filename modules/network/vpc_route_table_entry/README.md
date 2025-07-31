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
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_routes"></a> [routes](#input\_routes) | List of routes to be added to the route table | <pre>list(object({<br/>    route_table_id             = string<br/>    destination_cidr_block     = string<br/>    destination_prefix_list_id = optional(string)<br/>    gateway_id                 = optional(string)<br/>    nat_gateway_id             = optional(string)<br/>    network_interface_id       = optional(string)<br/>    transit_gateway_id         = optional(string)<br/>    vpc_peering_connection_id  = optional(string)<br/>    vpc_endpoint_id            = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of route IDs |
<!-- END_TF_DOCS -->