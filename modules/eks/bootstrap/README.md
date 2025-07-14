# `eks/bootstrap`

This module installs the "baseline" set of capabilities that all Cloud City EKS clusters should have, including:
- External Secrets operator.
- AWS Load Balancer controller.
- ArgoCD.
- EBS CSI system (with a default storage class, as well as a "retained" storage class whose volumes are not deleted once
  detached).

This module is separate from `eks/cluster` since it must be executed with a helm/kubernetes provider active and pointed
at the target cluster. Since provider initialization cannot be done lazily in Terraform, this necessitates a separate
module. Clusters provisioned in Cloud City should instantiate a `eks/cluster` first, then this module, with appropriate
dependencies configured via Terragrunt.

**Note:** when applying or destroying this module, the `argocd` Helm release can take quite some time to initialize or
to destroy, due to the long turnaround time and poller frequency in interacting with AWS load balancers via the LBC. If
things do time out related to ArgoCD, a good first place to look when debugging those issues is the `argocd-server`
`Service` (`LoadBalancer`) resource in the target EKS cluster. That resource's logs may indicate the reason for the
failure.

**Note:** Destroying this module will not necessarily destroy argo-deployed applications or Kubernetes resources created
by previous iterations of this module. If more thorough destruction is needed, use manual `kubectl` commands and/or
move the namespaces/resources containing destroy-needful objects into Terraform IaC as first-class `"resource"`s.

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
| <a name="module_alarms"></a> [alarms](#module\_alarms) | ./eks-automated-monitoring | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ../../helm | n/a |
| <a name="module_argocd_irsa_role"></a> [argocd\_irsa\_role](#module\_argocd\_irsa\_role) | ../service_account | n/a |
| <a name="module_awslbc"></a> [awslbc](#module\_awslbc) | ../../helm | n/a |
| <a name="module_awslbc_irsa_role"></a> [awslbc\_irsa\_role](#module\_awslbc\_irsa\_role) | ../service_account | n/a |
| <a name="module_external_secrets"></a> [external\_secrets](#module\_external\_secrets) | ../../helm | n/a |
| <a name="module_reloader_argocd_app"></a> [reloader\_argocd\_app](#module\_reloader\_argocd\_app) | ../../argocd/application | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.reloader](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_storage_class.ebs_sc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubernetes_service.argocd_server](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Internal name of the AWS account this is in. Used for auto-deploying cluster resources | `string` | n/a | yes |
| <a name="input_chart_ecr_image_account_id"></a> [chart\_ecr\_image\_account\_id](#input\_chart\_ecr\_image\_account\_id) | AWS Account ID containing chart images to be used by this module. Should not ordinarily be changed from the default (the infra account) | `string` | `"381492150796"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster | `string` | n/a | yes |
| <a name="input_enable_argocd"></a> [enable\_argocd](#input\_enable\_argocd) | Whether to provision ArgoCD on this cluster | `bool` | `true` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Whether to provision the AWS load balancer controller (LBC) on this cluster | `bool` | `true` | no |
| <a name="input_nodegroup_security_group_id"></a> [nodegroup\_security\_group\_id](#input\_nodegroup\_security\_group\_id) | Security group for the LoadBalancer to use | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_namespace"></a> [argocd\_namespace](#output\_argocd\_namespace) | Namespace of ArgoCD-server if 'enable\_argocd' is true, otherwise null |
| <a name="output_argocd_server_endpoint"></a> [argocd\_server\_endpoint](#output\_argocd\_server\_endpoint) | AWS load balancer URL for ArgoCD-server if 'enable\_argocd' is true, otherwise null |
| <a name="output_aws_ecr_service_account"></a> [aws\_ecr\_service\_account](#output\_aws\_ecr\_service\_account) | Service account for use with ArgoCD applications if 'enable\_argocd' is true, otherwise null |
<!-- END_TF_DOCS -->
