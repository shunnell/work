<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.argocd_helm_app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ecr_authorization_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ecr_oci_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_destination"></a> [app\_destination](#input\_app\_destination) | Destination server of the app | `string` | `"https://kubernetes.default.svc"` | no |
| <a name="input_app_helm_chart"></a> [app\_helm\_chart](#input\_app\_helm\_chart) | The Helm chart for the app. ex: 'reloader' | `string` | n/a | yes |
| <a name="input_app_helm_chart_repo"></a> [app\_helm\_chart\_repo](#input\_app\_helm\_chart\_repo) | Repository containing helm chart - not full path of helm chart. ex: '000.dkr.something.ecr.aws.com/platform/internal/helm/stakater' | `string` | n/a | yes |
| <a name="input_app_helm_chart_version"></a> [app\_helm\_chart\_version](#input\_app\_helm\_chart\_version) | Version of the Helm chart to use. ex: '1.2.3' | `string` | n/a | yes |
| <a name="input_app_helm_values"></a> [app\_helm\_values](#input\_app\_helm\_values) | App Helm chart values in YAML format. | `string` | `null` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the app. Defaults to value of 'app\_helm\_chart' if this is empty/null. | `string` | `""` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | Namespace that the app will be deployed to. | `string` | n/a | yes |
| <a name="input_argocd_app_project"></a> [argocd\_app\_project](#input\_argocd\_app\_project) | Project that this ArgoCD Application belongs to. Useful for tenant restrictions. | `string` | `"default"` | no |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Namespace of ArgoCD. | `string` | `"argocd"` | no |
| <a name="input_aws_ecr_service_account"></a> [aws\_ecr\_service\_account](#input\_aws\_ecr\_service\_account) | ServiceAccount with role for ECR access. Required when chart is in AWS ECR. | `string` | `null` | no |
| <a name="input_prune"></a> [prune](#input\_prune) | Prune app: https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-pruning | `bool` | `true` | no |
| <a name="input_self_heal"></a> [self\_heal](#input\_self\_heal) | Self-heal app: https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-self-healing | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->