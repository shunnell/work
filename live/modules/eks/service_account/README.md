<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa_role"></a> [irsa\_role](#module\_irsa\_role) | git::https://gitlab.cloud-city/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_service_account.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_openid_connect_provider.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster name (required by terraform provider setup even if not used by this module) | `string` | n/a | yes |
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | Whether to create the Kubernetes service acount that the IRSA role is bound to. Only disable this if the service account is unconditionally created elsewhere (e.g. in a helm chart which cannot disable the creation of its own SA) | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the purpose of this role | `string` | `""` | no |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | ARNs of any custom, externally-created policies to attach to the IAM role. | `set(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IRSA role (will be the name of the created service account, and the name *prefix* of the created IAM role) | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace in which service account should be created | `string` | n/a | yes |
| <a name="input_secret_arns"></a> [secret\_arns](#input\_secret\_arns) | ARNs SecretsManager secrets or KMS keys to grant this role permission to use via the external secrets operator. If empty, the external secrets operator's permissions won't be attached to this IRSA role. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add the the IAM role | `map(string)` | `{}` | no |
| <a name="input_use_cloudwatch_observability"></a> [use\_cloudwatch\_observability](#input\_use\_cloudwatch\_observability) | Whether or not to set up permissions for this IRSA role to use the CloudWatch observability addon | `bool` | `false` | no |
| <a name="input_use_cluster_autoscaler"></a> [use\_cluster\_autoscaler](#input\_use\_cluster\_autoscaler) | Whether or not to set up permissions for this IRSA role to use the cluster autoscaler controller | `bool` | `false` | no |
| <a name="input_use_load_balancer_controller"></a> [use\_load\_balancer\_controller](#input\_use\_load\_balancer\_controller) | Whether or not to set up permissions for this IRSA role to use the AWS Load Balancer controller | `bool` | `false` | no |
| <a name="input_use_name_as_iam_role_prefix"></a> [use\_name\_as\_iam\_role\_prefix](#input\_use\_name\_as\_iam\_role\_prefix) | Name of the IRSA role will be distinct (not a prefix) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | n/a |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | n/a |
<!-- END_TF_DOCS -->