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
| <a name="module_gitlab"></a> [gitlab](#module\_gitlab) | ../../helm | n/a |
| <a name="module_gitlab_secret_service_account"></a> [gitlab\_secret\_service\_account](#module\_gitlab\_secret\_service\_account) | ../../eks/service_account | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.rds_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.redis_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.gitlab_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_priority_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/priority_class) | resource |
| [kubernetes_secret.rails_s3_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.s3cmd_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_cert_arn"></a> [acm\_cert\_arn](#input\_acm\_cert\_arn) | ACM cert arn for ingress https connection | `string` | `null` | no |
| <a name="input_artifacts_bucket"></a> [artifacts\_bucket](#input\_artifacts\_bucket) | Bucket for artifacts | `string` | `null` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the GitLab Helm chart to install | `string` | `null` | no |
| <a name="input_ci_secure_bucket"></a> [ci\_secure\_bucket](#input\_ci\_secure\_bucket) | Bucket for ci secure | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_dependency_proxy_bucket"></a> [dependency\_proxy\_bucket](#input\_dependency\_proxy\_bucket) | Bucket for dependency proxy | `string` | `null` | no |
| <a name="input_gitlab_backup_bucket"></a> [gitlab\_backup\_bucket](#input\_gitlab\_backup\_bucket) | Bucket for gitlab backup | `string` | `null` | no |
| <a name="input_gitlab_domain"></a> [gitlab\_domain](#input\_gitlab\_domain) | Domain name for GitLab | `string` | n/a | yes |
| <a name="input_gitlab_image_registry_root"></a> [gitlab\_image\_registry\_root](#input\_gitlab\_image\_registry\_root) | Registry root to be used for runners to find runner, helper, and default job images (note: this does not set a default registry for user jobs; they'll still need explicit full paths for images in specific registries) | `string` | `"381492150796.dkr.ecr.us-east-1.amazonaws.com/platform"` | no |
| <a name="input_gitlab_lfs_bucket"></a> [gitlab\_lfs\_bucket](#input\_gitlab\_lfs\_bucket) | Bucket for gitlab lfs | `string` | `null` | no |
| <a name="input_gitlab_namespace"></a> [gitlab\_namespace](#input\_gitlab\_namespace) | Kubernetes namespace where GitLab will be deployed | `string` | `"gitlab"` | no |
| <a name="input_gitlab_pkg_bucket"></a> [gitlab\_pkg\_bucket](#input\_gitlab\_pkg\_bucket) | Bucket for gitlab pkg | `string` | `null` | no |
| <a name="input_gitlab_tmp_backup_bucket"></a> [gitlab\_tmp\_backup\_bucket](#input\_gitlab\_tmp\_backup\_bucket) | Bucket for gitlab tmp backup | `string` | `null` | no |
| <a name="input_gitlab_uploads_bucket"></a> [gitlab\_uploads\_bucket](#input\_gitlab\_uploads\_bucket) | Bucket for gitlab uploads | `string` | `null` | no |
| <a name="input_irsa_name"></a> [irsa\_name](#input\_irsa\_name) | Name of the IAM role for IRSA (IAM Roles for Service Accounts) | `string` | `"service-account"` | no |
| <a name="input_irsa_role"></a> [irsa\_role](#input\_irsa\_role) | IAM role ARN for IRSA (IAM Roles for Service Accounts) | `string` | `null` | no |
| <a name="input_mr_diffs_bucket"></a> [mr\_diffs\_bucket](#input\_mr\_diffs\_bucket) | Bucket for mr diffs | `string` | `null` | no |
| <a name="input_rails_s3_secret_name"></a> [rails\_s3\_secret\_name](#input\_rails\_s3\_secret\_name) | Rails s3 secret | `string` | `"rails-s3-config"` | no |
| <a name="input_rds_aws_secret"></a> [rds\_aws\_secret](#input\_rds\_aws\_secret) | AWS secret name for RDS credentials | `string` | `"postgres-secret"` | no |
| <a name="input_rds_endpoint"></a> [rds\_endpoint](#input\_rds\_endpoint) | RDS endpoint | `string` | `null` | no |
| <a name="input_rds_secret"></a> [rds\_secret](#input\_rds\_secret) | Name of the Kubernetes secret containing RDS credentials | `string` | `"postgres-secret"` | no |
| <a name="input_redis_aws_secret"></a> [redis\_aws\_secret](#input\_redis\_aws\_secret) | AWS secret name for Redis credentials | `string` | `"redis-secret"` | no |
| <a name="input_redis_endpoint"></a> [redis\_endpoint](#input\_redis\_endpoint) | Endpoint URL for the Redis instance | `string` | `null` | no |
| <a name="input_redis_secret"></a> [redis\_secret](#input\_redis\_secret) | Name of the Kubernetes secret containing Redis credentials | `string` | `"redis-secret"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Name of the GitLab Helm release | `string` | `null` | no |
| <a name="input_s3_secret_name"></a> [s3\_secret\_name](#input\_s3\_secret\_name) | Secret name for s3 config | `string` | `"s3cmd-config"` | no |
| <a name="input_secret_arn"></a> [secret\_arn](#input\_secret\_arn) | List of secret arns should be allowed for the service account | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_tf_state_bucket"></a> [tf\_state\_bucket](#input\_tf\_state\_bucket) | Bucket for tf state | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_namespace"></a> [gitlab\_namespace](#output\_gitlab\_namespace) | n/a |
| <a name="output_priority_class"></a> [priority\_class](#output\_priority\_class) | n/a |
| <a name="output_rds_secret_name"></a> [rds\_secret\_name](#output\_rds\_secret\_name) | n/a |
<!-- END_TF_DOCS -->