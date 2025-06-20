# Kubernetes repo applications

Deploy a bunch of useful things on an EKS cluster to get it started.

## Prerequisites

- Have set up `live` repo IaC per the [setup instructions](https://gitlab.cloud-city/cloud-city/platform/iac/live/-/blob/main/_doc/setup.md).
- Current/updated checkouts of the `live`, `modules` and `kubernetes` repositories

## Example usage

Examples of using this module (which only works in the `infra` account at this time) can be found here:

- https://gitlab.cloud-city/cloud-city/platform/iac/live/-/tree/main/infra/platform/admin/admin_eks

## Creating and Inspecting

First, install and configure `kubectl` and the AWS CLI.

Then, open a terminal in the directory to validate the configuration:
```shell
terragrunt apply "tfplan"
aws eks update-kubeconfig --region us-east-1 --name <cluster-name> --alias <account>-<cluster-name>
kubectl get namespaces
```
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
| <a name="module_k8s_secret_access_service_account"></a> [k8s\_secret\_access\_service\_account](#module\_k8s\_secret\_access\_service\_account) | ../service_account | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.kubernetes_repo_application](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.repo_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Kubernetes namespace which contains ArgoCD | `string` | `"argocd"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster | `string` | n/a | yes |
| <a name="input_config_path"></a> [config\_path](#input\_config\_path) | Root path for the cluster deployment | `string` | `"_base/_infrastructure"` | no |
| <a name="input_k8s_repo_secret_name"></a> [k8s\_repo\_secret\_name](#input\_k8s\_repo\_secret\_name) | Name of the deploy key and user for the repo in Secret Manager | `string` | n/a | yes |
| <a name="input_k8s_repo_secret_token_key"></a> [k8s\_repo\_secret\_token\_key](#input\_k8s\_repo\_secret\_token\_key) | Name of the deploy key for the repo in Secret Manager | `string` | `"key"` | no |
| <a name="input_k8s_repo_secret_user_key"></a> [k8s\_repo\_secret\_user\_key](#input\_k8s\_repo\_secret\_user\_key) | Name of the deploy user for the repo in Secret Manager | `string` | `"user"` | no |
| <a name="input_k8s_repo_target_revision"></a> [k8s\_repo\_target\_revision](#input\_k8s\_repo\_target\_revision) | Revision/branch/tag to reference in target repository | `string` | `"HEAD"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->