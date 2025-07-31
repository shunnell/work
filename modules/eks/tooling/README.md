# Kubernetes Tooling

This module contains all the additional tools for the Kubernetes clusters.  This depends on the [bootstrap](../bootstrap) module being applied as a Terragrunt unit first, because these tools are applied to the cluster as ArgoCD Applications so that ArgoCD can manage it and provide a UI to monitor these tools.

## Destroying or replacing the Traefik LoadBalancer Service or the associated AWS Network Load Balancer

Deletion protection is enabled.  Disable it through the parameter in the annotation of the Traefik LoadBalancer Service.  Once this has propogated to the associated AWS Network Load Balancer, the resources can be destroyed or replaced.

# Terraform Docs

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
| <a name="module_awslbc"></a> [awslbc](#module\_awslbc) | ../../argocd/application | n/a |
| <a name="module_awslbc_irsa_role"></a> [awslbc\_irsa\_role](#module\_awslbc\_irsa\_role) | ../service_account | n/a |
| <a name="module_awspca_irsa_role"></a> [awspca\_irsa\_role](#module\_awspca\_irsa\_role) | ../service_account | n/a |
| <a name="module_awspca_issuer"></a> [awspca\_issuer](#module\_awspca\_issuer) | ../../argocd/application | n/a |
| <a name="module_awspca_policy"></a> [awspca\_policy](#module\_awspca\_policy) | ../../iam/policy | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ../../argocd/application | n/a |
| <a name="module_reloader_argocd_app"></a> [reloader\_argocd\_app](#module\_reloader\_argocd\_app) | ../../argocd/application | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | ../../argocd/application | n/a |
| <a name="module_traefik_crds"></a> [traefik\_crds](#module\_traefik\_crds) | ../../argocd/application | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.awspca_attachement](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of allowed CIDRs that may access services through the LB | `list(string)` | n/a | yes |
| <a name="input_api_gateway_replicas"></a> [api\_gateway\_replicas](#input\_api\_gateway\_replicas) | Replicas of API Gateway controller | `number` | `2` | no |
| <a name="input_argocd_domain_name"></a> [argocd\_domain\_name](#input\_argocd\_domain\_name) | Domain name for ArgoCD deployed in cluster | `string` | n/a | yes |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Namespace of ArgoCD deployment | `string` | n/a | yes |
| <a name="input_aws_ecr_service_account"></a> [aws\_ecr\_service\_account](#input\_aws\_ecr\_service\_account) | Service account for use with ArgoCD applications | `string` | n/a | yes |
| <a name="input_aws_lbc_helm_chart_version"></a> [aws\_lbc\_helm\_chart\_version](#input\_aws\_lbc\_helm\_chart\_version) | Version of the Helm chart for AWS Load Balancer Controller | `string` | `"1.13.3"` | no |
| <a name="input_aws_pca_helm_chart_version"></a> [aws\_pca\_helm\_chart\_version](#input\_aws\_pca\_helm\_chart\_version) | Version of the Helm chart for AWS Private CA | `string` | `"v1.6.0"` | no |
| <a name="input_cert_manager_helm_chart_version"></a> [cert\_manager\_helm\_chart\_version](#input\_cert\_manager\_helm\_chart\_version) | Version of the Helm chart for Cert-Manager | `string` | `"v1.18.2"` | no |
| <a name="input_chart_ecr_image_account_id"></a> [chart\_ecr\_image\_account\_id](#input\_chart\_ecr\_image\_account\_id) | AWS Account ID containing chart images to be used by this module. Should not ordinarily be changed from the default (the infra account) | `string` | `"381492150796"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster | `string` | n/a | yes |
| <a name="input_nodegroup_security_group_id"></a> [nodegroup\_security\_group\_id](#input\_nodegroup\_security\_group\_id) | Security group for all nodes; will disable the AWS Load Balancer Controller if null | `string` | n/a | yes |
| <a name="input_reloader_helm_chart_version"></a> [reloader\_helm\_chart\_version](#input\_reloader\_helm\_chart\_version) | Version of the Helm chart for Reloader | `string` | `"2.1.4"` | no |
| <a name="input_root_ca_arn"></a> [root\_ca\_arn](#input\_root\_ca\_arn) | ARN of the root CA | `string` | n/a | yes |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | Domain name that this cluster is expecting to recieve traffic on, including subdomains. Ex: data-platform.sandbox.cloud-city, or dev.cloud-city | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources | `map(string)` | `{}` | no |
| <a name="input_traefik_crds_helm_chart_version"></a> [traefik\_crds\_helm\_chart\_version](#input\_traefik\_crds\_helm\_chart\_version) | Version of the Helm chart for Traefik and Gateway API CRDs | `string` | `"1.9.0"` | no |
| <a name="input_traefik_helm_chart_version"></a> [traefik\_helm\_chart\_version](#input\_traefik\_helm\_chart\_version) | Version of the Helm chart for Traefik | `string` | `"36.3.0"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID; will disable the AWS Load Balancer Controller if null | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_issuer"></a> [cluster\_issuer](#output\_cluster\_issuer) | Cluster certificate issuer name |
| <a name="output_gateway_class_name"></a> [gateway\_class\_name](#output\_gateway\_class\_name) | Name of the GatewayClass |
| <a name="output_ingress_class_name"></a> [ingress\_class\_name](#output\_ingress\_class\_name) | Name of the IngressClass |
| <a name="output_web_port"></a> [web\_port](#output\_web\_port) | Port for inbound HTTP traffic |
| <a name="output_websecure_port"></a> [websecure\_port](#output\_websecure\_port) | Port for inbound HTTPS traffic |
<!-- END_TF_DOCS -->