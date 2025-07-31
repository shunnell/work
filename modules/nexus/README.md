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
| <a name="module_nexus"></a> [nexus](#module\_nexus) | ../helm | n/a |
| <a name="module_nexus_service_account"></a> [nexus\_service\_account](#module\_nexus\_service\_account) | ../eks/service_account | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.http_route](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.license_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.rds_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.nexus_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_busybox_version"></a> [busybox\_version](#input\_busybox\_version) | The version of the busybox image to use | `string` | `"1.33.1"` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | The chart to install | `string` | `"nxrm-ha"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of the chart to install | `string` | n/a | yes |
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | The cluster issuer to use | `string` | `"bespin-root-ca"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster | `string` | n/a | yes |
| <a name="input_db_endpoint"></a> [db\_endpoint](#input\_db\_endpoint) | The endpoint of the database | `string` | n/a | yes |
| <a name="input_docker_acm_certificate_arn"></a> [docker\_acm\_certificate\_arn](#input\_docker\_acm\_certificate\_arn) | The ARN of the ACM certificate to use for the Docker registry | `string` | n/a | yes |
| <a name="input_ecr_docker_hub"></a> [ecr\_docker\_hub](#input\_ecr\_docker\_hub) | The ECR host for the Docker hub | `string` | n/a | yes |
| <a name="input_ecr_host"></a> [ecr\_host](#input\_ecr\_host) | The ECR host for the Nexus chart | `string` | n/a | yes |
| <a name="input_env_suffix"></a> [env\_suffix](#input\_env\_suffix) | Suffix to use for resource names (e.g., 'test' for test stacks, '' for production) | `string` | `""` | no |
| <a name="input_gateway_class_name"></a> [gateway\_class\_name](#input\_gateway\_class\_name) | The gateway class name to use | `string` | `"traefik"` | no |
| <a name="input_license_secret_arn"></a> [license\_secret\_arn](#input\_license\_secret\_arn) | The ARN of the license secret | `string` | n/a | yes |
| <a name="input_license_secret_key"></a> [license\_secret\_key](#input\_license\_secret\_key) | The key of the license secret | `string` | n/a | yes |
| <a name="input_license_secret_name"></a> [license\_secret\_name](#input\_license\_secret\_name) | Name of the Kubernetes secret containing license credentials | `string` | `"nexus-repo-license.lic"` | no |
| <a name="input_nexus_acm_certificate_arn"></a> [nexus\_acm\_certificate\_arn](#input\_nexus\_acm\_certificate\_arn) | The ARN of the ACM certificate to use | `string` | n/a | yes |
| <a name="input_nexus_domain_name"></a> [nexus\_domain\_name](#input\_nexus\_domain\_name) | The domain name for the Nexus service | `string` | n/a | yes |
| <a name="input_rds_aws_secret"></a> [rds\_aws\_secret](#input\_rds\_aws\_secret) | AWS secret name for RDS credentials | `string` | n/a | yes |
| <a name="input_rds_secret"></a> [rds\_secret](#input\_rds\_secret) | Name of the Kubernetes secret containing RDS credentials | `string` | `"postgres-secret"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | The name of the release | `string` | n/a | yes |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | The number of replicas to run | `number` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | The repository of the chart to install | `string` | n/a | yes |
| <a name="input_secret_arn"></a> [secret\_arn](#input\_secret\_arn) | The ARN of the secret to use | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nexus_deployment"></a> [nexus\_deployment](#output\_nexus\_deployment) | The state of the helm deployment |
| <a name="output_nexus_namespace"></a> [nexus\_namespace](#output\_nexus\_namespace) | n/a |
<!-- END_TF_DOCS -->