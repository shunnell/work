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
| <a name="module_codeartifact_identity_policy"></a> [codeartifact\_identity\_policy](#module\_codeartifact\_identity\_policy) | ../../codeartifact/identity_policy_for_repo_access | n/a |
| <a name="module_gitlab_runner"></a> [gitlab\_runner](#module\_gitlab\_runner) | ../../helm | n/a |
| <a name="module_runner_cache_s3_bucket"></a> [runner\_cache\_s3\_bucket](#module\_runner\_cache\_s3\_bucket) | ../../s3 | n/a |
| <a name="module_runner_iam_policy"></a> [runner\_iam\_policy](#module\_runner\_iam\_policy) | ../../iam/policy | n/a |
| <a name="module_runner_iam_role"></a> [runner\_iam\_role](#module\_runner\_iam\_role) | ../../eks/service_account | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.fleet_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.gitlab_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_storage_class.runner_ebs_sc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret_version.gitlab_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_builder_cpu"></a> [builder\_cpu](#input\_builder\_cpu) | Minimum CPU allocated for runner main | `string` | `"500m"` | no |
| <a name="input_builder_memory"></a> [builder\_memory](#input\_builder\_memory) | Memory allocated for runner main | `string` | `"2Gi"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the GitLab Runners Helm chart to install | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster that will contain the runners | `string` | n/a | yes |
| <a name="input_code_artifact_repos"></a> [code\_artifact\_repos](#input\_code\_artifact\_repos) | ARNs for CodeArtifact repositories to which this fleet should have access | <pre>object({<br/>    pull         = set(string)<br/>    push         = set(string)<br/>    pull_through = set(string)<br/>  })</pre> | <pre>{<br/>  "pull": [],<br/>  "pull_through": [],<br/>  "push": []<br/>}</pre> | no |
| <a name="input_concurrency_jobs_per_pod"></a> [concurrency\_jobs\_per\_pod](#input\_concurrency\_jobs\_per\_pod) | How many jobs can be run within each runner pod | `number` | `6` | no |
| <a name="input_concurrency_pods"></a> [concurrency\_pods](#input\_concurrency\_pods) | How many runner pods to provision | `number` | `4` | no |
| <a name="input_deployer_roles"></a> [deployer\_roles](#input\_deployer\_roles) | List of IAM Role ARNs (potentially in other accounts) that these runners can assume (remote roles will need trust policies that allow the runner role to assume them) | `list(string)` | `[]` | no |
| <a name="input_gitlab_certificate"></a> [gitlab\_certificate](#input\_gitlab\_certificate) | SSL certificate used for authenticating the runners with the mothership | `string` | n/a | yes |
| <a name="input_gitlab_certificate_path"></a> [gitlab\_certificate\_path](#input\_gitlab\_certificate\_path) | Location to mount the GitLab certificate | `string` | `"/etc/gitlab-runner/certs/"` | no |
| <a name="input_gitlab_mothership_domain"></a> [gitlab\_mothership\_domain](#input\_gitlab\_mothership\_domain) | Domain of the GitLab mothership server. Must be reachable from the EKS cluster's nodegroup security group. | `string` | n/a | yes |
| <a name="input_gitlab_secret_id"></a> [gitlab\_secret\_id](#input\_gitlab\_secret\_id) | AWS Secrets Manager ID containing the GitLab instance's secrets, including runner join tokens. The secret at this ID must contain a JSON object with a key corresponding to 'runner\_fleet\_name' and a value containing 'token' with the join token for this fleet. | `string` | n/a | yes |
| <a name="input_read_only_root"></a> [read\_only\_root](#input\_read\_only\_root) | If true, mount the filesystem in the root container as read-only. Only /builds (and a few other log/cache folders) will be read-write. This prevents ephemeral storage exhaustion by code that writes outside of /builds. | `bool` | `false` | no |
| <a name="input_runner_fleet_name_suffix"></a> [runner\_fleet\_name\_suffix](#input\_runner\_fleet\_name\_suffix) | Suffix to be added to var.tenant name to identify resources related to these runners. $tenant\_name-$runner\_fleet\_name\_suffix must be globally unique in the account | `string` | `"default"` | no |
| <a name="input_runner_iam_policy_attachments"></a> [runner\_iam\_policy\_attachments](#input\_runner\_iam\_policy\_attachments) | List of IAM policy ARNs to attach to the runners' role | `list(string)` | `[]` | no |
| <a name="input_runner_image_registry_root"></a> [runner\_image\_registry\_root](#input\_runner\_image\_registry\_root) | Registry root to be used for runners to find runner, helper, and default job images (note: this does not set a default registry for user jobs; they'll still need explicit full paths for images in specific registries) | `string` | `"381492150796.dkr.ecr.us-east-1.amazonaws.com"` | no |
| <a name="input_runner_is_privilaged"></a> [runner\_is\_privilaged](#input\_runner\_is\_privilaged) | Will runners run in privilaged mode? | `bool` | `false` | no |
| <a name="input_scratch_space_size_gb"></a> [scratch\_space\_size\_gb](#input\_scratch\_space\_size\_gb) | Scratch space size that will be mounted at /builds | `number` | `6` | no |
| <a name="input_service_cpu"></a> [service\_cpu](#input\_service\_cpu) | Minimum CPU allocated for runner service | `string` | `"500m"` | no |
| <a name="input_service_memory"></a> [service\_memory](#input\_service\_memory) | Memory allocated for runner service | `string` | `"512Mi"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | Name of the tenant whose jobs run on these runners | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runner_iam_role_arn"></a> [runner\_iam\_role\_arn](#output\_runner\_iam\_role\_arn) | ARN of the IAM role runners will use inside the EKS cluster |
| <a name="output_runner_namespace"></a> [runner\_namespace](#output\_runner\_namespace) | Namespace containing these runners (and nothing else) |
<!-- END_TF_DOCS -->