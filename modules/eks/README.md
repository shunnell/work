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
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_log_types"></a> [cluster\_log\_types](#input\_cluster\_log\_types) | Enabled Cluster Log Types | `list(string)` | <pre>[<br/>  "api",<br/>  "audit",<br/>  "authenticator",<br/>  "controllerManager",<br/>  "scheduler"<br/>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster | `string` | n/a | yes |
| <a name="input_cluster_role_arn"></a> [cluster\_role\_arn](#input\_cluster\_role\_arn) | Cluster Role ARN | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | K8s Version | `string` | `"1.31"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Node Groups | <pre>list(object({<br/>    ami_type      = optional(string, "BOTTLEROCKET_x86_64")<br/>    capacity_type = optional(string, "ON_DEMAND")<br/>    desired_size  = optional(number, 3)<br/>    disk_size     = optional(number, 20)<br/>    instance_type = optional(string, "t3.medium")<br/>    max_size      = optional(number, 6)<br/>    min_size      = optional(number, 3)<br/>    name          = string<br/>    node_role_arn = string<br/>  }))</pre> | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security Group IDs | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_sg_id"></a> [vpc\_endpoint\_sg\_id](#input\_vpc\_endpoint\_sg\_id) | VPC Endpoint Security Group ID | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Cluster ID |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | The security group ID of the EKS cluster |
| <a name="output_node_group_ami_types"></a> [node\_group\_ami\_types](#output\_node\_group\_ami\_types) | AMI type for the node group |
| <a name="output_node_group_capacity_types"></a> [node\_group\_capacity\_types](#output\_node\_group\_capacity\_types) | Capacity type for the node group |
| <a name="output_node_group_ids"></a> [node\_group\_ids](#output\_node\_group\_ids) | Node Group IDs |
| <a name="output_node_group_instance_types"></a> [node\_group\_instance\_types](#output\_node\_group\_instance\_types) | Instance type for the node group |
<!-- END_TF_DOCS -->