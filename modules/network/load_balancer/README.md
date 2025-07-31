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
| <a name="module_lb_sg"></a> [lb\_sg](#module\_lb\_sg) | ../security_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_lb.load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of Load Balancer | `string` | `"network"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used to name all resources | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_target_ports"></a> [target\_ports](#input\_target\_ports) | The ports create Target Groups for | <pre>map(object({<br/>    protocol           = optional(string, "TCP")<br/>    target_type        = optional(string, "ip")<br/>    proxy_protocol_v2  = optional(bool)<br/>    preserve_client_ip = optional(bool)<br/>    health_check = optional(object({<br/>      path     = optional(string)<br/>      protocol = optional(string)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_target_rules"></a> [target\_rules](#input\_target\_rules) | Target rules for Load Balancer security group; {'rule one' = {target = 'sg-123', type = 'egress'}} | <pre>map(object({<br/>    target = string<br/>    type   = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | The ARN of the Load Balancer |
| <a name="output_load_balancer_dns"></a> [load\_balancer\_dns](#output\_load\_balancer\_dns) | The DNS of the Load Balance |
| <a name="output_load_balancer_name"></a> [load\_balancer\_name](#output\_load\_balancer\_name) | The name of the Load Balancer |
| <a name="output_load_balancer_security_group_arn"></a> [load\_balancer\_security\_group\_arn](#output\_load\_balancer\_security\_group\_arn) | ARN of the Security Group for the Load Balancer |
| <a name="output_load_balancer_security_group_id"></a> [load\_balancer\_security\_group\_id](#output\_load\_balancer\_security\_group\_id) | ID of the Security Group for the Load Balancer |
| <a name="output_load_balancer_subnet_mappings"></a> [load\_balancer\_subnet\_mappings](#output\_load\_balancer\_subnet\_mappings) | Subnet mappings for the Load Balancer |
| <a name="output_load_balancer_target_groups"></a> [load\_balancer\_target\_groups](#output\_load\_balancer\_target\_groups) | The target groups for the Load Balancer |
| <a name="output_load_balancer_type"></a> [load\_balancer\_type](#output\_load\_balancer\_type) | The type of the Load Balancer - used in k8s lb service annotations |
| <a name="output_load_balancer_zone_id"></a> [load\_balancer\_zone\_id](#output\_load\_balancer\_zone\_id) | Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
<!-- END_TF_DOCS -->