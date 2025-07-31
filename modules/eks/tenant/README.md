# Dependencies

This module requires that application of the [eks/tooling](../tooling) module first.

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
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | CA certificate issure | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_gateway_class_name"></a> [gateway\_class\_name](#input\_gateway\_class\_name) | Name of the GatewayClass | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tenant_domain_names"></a> [tenant\_domain\_names](#input\_tenant\_domain\_names) | Domain names for tenant traffic. Ex: data-platform.dev.cloud-city, or iva.test.cloud-city | `map(string)` | n/a | yes |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | Name of the tenant - for namespace and other resources | `string` | n/a | yes |
| <a name="input_web_port"></a> [web\_port](#input\_web\_port) | Port for insecure inbound traffic (8000). This comes from the gateway api port, not the exposed service port | `number` | n/a | yes |
| <a name="input_websecure_port"></a> [websecure\_port](#input\_websecure\_port) | Port for secure inbound traffic (8443). This comes from the gateway api port, not the exposed service port | `number` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->