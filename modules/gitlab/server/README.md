# GitLab Server

## Enabling ROOT user login

1. connect to the 'toolbox' pod
1. launch rails console
    1. `gitlab-rails console`
    1. wait
1. enable 'root' user
    1. `user = User.find_by_username('root')`
    1. `user.activate!`
    1. `user.password = 'xxx'`
        1. create a new password to remember
        1. or copy the initial password from the secret
    1. `user.password_confirmation = 'xxx'`
    1. `user.save!`
    1. `user.state`
1. enable web login
    1. `s = ApplicationSetting.current`
    1. `s.password_authentication_enabled_for_web = true`
    1. `s.save!`
1. restart the webservice pods

## Disabling Maintenance mode

1. connect to the 'toolbox' pod
1. launch rails console
    1. `gitlab-rails console`
    1. wait
1. `ApplicationSetting.current.update_attribute(:maintenance_mode, false)`
1. restart the webservice pods


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
| [kubernetes_secret.okta_saml_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.rails_s3_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.rails_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.s3cmd_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_storage_class.gitaly_retain](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret_version.gitlab_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_cert_arn"></a> [acm\_cert\_arn](#input\_acm\_cert\_arn) | ACM cert arn for ingress https connection | `string` | n/a | yes |
| <a name="input_artifacts_bucket"></a> [artifacts\_bucket](#input\_artifacts\_bucket) | Bucket for artifacts | `string` | n/a | yes |
| <a name="input_backup_bucket"></a> [backup\_bucket](#input\_backup\_bucket) | Bucket for gitlab backup | `string` | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the GitLab Helm chart to install | `string` | n/a | yes |
| <a name="input_ci_secure_bucket"></a> [ci\_secure\_bucket](#input\_ci\_secure\_bucket) | Bucket for ci secure | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_dependency_proxy_bucket"></a> [dependency\_proxy\_bucket](#input\_dependency\_proxy\_bucket) | Bucket for dependency proxy | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name for GitLab | `string` | n/a | yes |
| <a name="input_gitlab_secret_id"></a> [gitlab\_secret\_id](#input\_gitlab\_secret\_id) | AWS Secrets Manager ID containing the GitLab instance's secrets, including OAuth token.<br/>The secret at this ID must contain a JSON object with a key corresponding to 'oauth\_token' and a value of the oauth token. | `string` | n/a | yes |
| <a name="input_image_registry_root"></a> [image\_registry\_root](#input\_image\_registry\_root) | Registry root to be used for runners to find runner, helper, and default job images (note: this does not set a default registry for user jobs; they'll still need explicit full paths for images in specific registries) | `string` | `"381492150796.dkr.ecr.us-east-1.amazonaws.com/platform"` | no |
| <a name="input_irsa_name"></a> [irsa\_name](#input\_irsa\_name) | Name of the IAM role for IRSA (IAM Roles for Service Accounts) | `string` | `"service-account"` | no |
| <a name="input_irsa_role"></a> [irsa\_role](#input\_irsa\_role) | IAM role ARN for IRSA (IAM Roles for Service Accounts) | `string` | n/a | yes |
| <a name="input_lfs_bucket"></a> [lfs\_bucket](#input\_lfs\_bucket) | Bucket for gitlab lfs | `string` | n/a | yes |
| <a name="input_mr_diffs_bucket"></a> [mr\_diffs\_bucket](#input\_mr\_diffs\_bucket) | Bucket for mr diffs | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where GitLab will be deployed | `string` | n/a | yes |
| <a name="input_pages_bucket"></a> [pages\_bucket](#input\_pages\_bucket) | Bucket for gitlab pages | `string` | n/a | yes |
| <a name="input_pkg_bucket"></a> [pkg\_bucket](#input\_pkg\_bucket) | Bucket for gitlab pkg | `string` | n/a | yes |
| <a name="input_rails_s3_secret_name"></a> [rails\_s3\_secret\_name](#input\_rails\_s3\_secret\_name) | Rails s3 secret | `string` | `"rails-s3-config"` | no |
| <a name="input_rds_aws_secret"></a> [rds\_aws\_secret](#input\_rds\_aws\_secret) | AWS secret name for RDS credentials | `string` | `"postgres-secret"` | no |
| <a name="input_rds_endpoint"></a> [rds\_endpoint](#input\_rds\_endpoint) | RDS endpoint | `string` | n/a | yes |
| <a name="input_rds_secret"></a> [rds\_secret](#input\_rds\_secret) | Name of the Kubernetes secret containing RDS credentials | `string` | `"postgres-secret"` | no |
| <a name="input_redis_aws_secret"></a> [redis\_aws\_secret](#input\_redis\_aws\_secret) | AWS secret name for Redis credentials | `string` | `"redis-secret"` | no |
| <a name="input_redis_endpoint"></a> [redis\_endpoint](#input\_redis\_endpoint) | Endpoint URL for the Redis instance | `string` | n/a | yes |
| <a name="input_redis_secret"></a> [redis\_secret](#input\_redis\_secret) | Name of the Kubernetes secret containing Redis credentials | `string` | `"redis-secret"` | no |
| <a name="input_registry_bucket"></a> [registry\_bucket](#input\_registry\_bucket) | Bucket for gitlab registry | `string` | n/a | yes |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Name of the GitLab Helm release | `string` | n/a | yes |
| <a name="input_s3_secret_name"></a> [s3\_secret\_name](#input\_s3\_secret\_name) | Secret name for s3 config | `string` | `"s3cmd-config"` | no |
| <a name="input_secret_arn"></a> [secret\_arn](#input\_secret\_arn) | List of secret arns should be allowed for the service account | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_tf_state_bucket"></a> [tf\_state\_bucket](#input\_tf\_state\_bucket) | Bucket for tf state | `string` | n/a | yes |
| <a name="input_tmp_backup_bucket"></a> [tmp\_backup\_bucket](#input\_tmp\_backup\_bucket) | Bucket for gitlab tmp backup | `string` | n/a | yes |
| <a name="input_uploads_bucket"></a> [uploads\_bucket](#input\_uploads\_bucket) | Bucket for gitlab uploads | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_namespace"></a> [gitlab\_namespace](#output\_gitlab\_namespace) | n/a |
| <a name="output_priority_class"></a> [priority\_class](#output\_priority\_class) | n/a |
| <a name="output_rds_secret_name"></a> [rds\_secret\_name](#output\_rds\_secret\_name) | n/a |
<!-- END_TF_DOCS -->