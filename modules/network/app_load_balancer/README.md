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
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the ACM certificate to use on the HTTPS listener. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used to name all resources (e.g. 'env-app'). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the ALB. | `string` | `"us-east-1"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to the ALB. | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs (at least two) where the ALB will attach. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_tenants"></a> [tenants](#input\_tenants) | Map of tenant configurations. Each key is an arbitrary tenant‐identifier string,<br/>and each value is an object with:<br/>- host\_header       = the hostname to match (e.g. 'tenant1.example.com')<br/>- priority          = integer priority for listener rule (1–50000)<br/>- port              = port that the tenant’s application listens on (e.g. 80 or 8080)<br/>- protocol          = (optional) protocol for the target group (defaults to "HTTP")<br/>- health\_check\_path = (optional) path for health checks (defaults to "/") | <pre>map(object({<br/>    host_header       = string<br/>    priority          = number<br/>    port              = number<br/>    protocol          = optional(string)<br/>    health_check_path = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the ALB and target groups will live. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer. |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the ALB (to use in Route 53, etc.). |
| <a name="output_alb_name_prefix"></a> [alb\_name\_prefix](#output\_alb\_name\_prefix) | Prefix used for naming ALB-related resources. |
| <a name="output_alb_security_groups"></a> [alb\_security\_groups](#output\_alb\_security\_groups) | List of security groups attached to the ALB. |
| <a name="output_tenant_target_group_arns"></a> [tenant\_target\_group\_arns](#output\_tenant\_target\_group\_arns) | Map of tenant‐key → corresponding target group ARN. |
<!-- END_TF_DOCS -->