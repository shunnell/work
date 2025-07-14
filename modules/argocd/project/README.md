# TODO
https://argo-cd.readthedocs.io/en/stable/user-guide/projects/

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.argocd_app_project](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Namespace of ArgoCD deployemnt | `string` | `"argocd"` | no |
| <a name="input_project_configuration"></a> [project\_configuration](#input\_project\_configuration) | Configuration of AppProject. Please reference https://argo-cd.readthedocs.io/en/stable/user-guide/projects/ for specification | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the ArgoCD AppProject | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->