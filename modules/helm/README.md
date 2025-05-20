# Helm module

## Login

```shell
aws ecr get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin 381492150796.dkr.ecr.us-east-1.amazonaws.com
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail | `bool` | `false` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. A path may be used | `string` | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `null` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Should the namespace be created if it does not exist? | `bool` | `false` | no |
| <a name="input_dependency_update"></a> [dependency\_update](#input\_dependency\_update) | Run helm dependency update before installing the chart | `bool` | `true` | no |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update) | Force resource update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_max_history"></a> [max\_history](#input\_max\_history) | Limit the maximum number of revisions saved per release. Use 0 for no limit | `number` | `3` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install chart into | `string` | `"default"` | no |
| <a name="input_recreate_pods"></a> [recreate\_pods](#input\_recreate\_pods) | Perform pods restart during upgrade/rollback | `bool` | `true` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Release name. The length must not be longer than 53 characters | `string` | n/a | yes |
| <a name="input_replace"></a> [replace](#input\_replace) | Re-use the given name, even if that name is already used. This is unsafe in production | `bool` | `false` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository where to locate the requested chart. If is a URL the chart is installed without installing the repository | `string` | `null` | no |
| <a name="input_repository_ca_file"></a> [repository\_ca\_file](#input\_repository\_ca\_file) | n/a | `string` | `null` | no |
| <a name="input_repository_cert_file"></a> [repository\_cert\_file](#input\_repository\_cert\_file) | n/a | `string` | `null` | no |
| <a name="input_repository_key_file"></a> [repository\_key\_file](#input\_repository\_key\_file) | n/a | `string` | `null` | no |
| <a name="input_repository_password"></a> [repository\_password](#input\_repository\_password) | n/a | `string` | `null` | no |
| <a name="input_repository_username"></a> [repository\_username](#input\_repository\_username) | n/a | `string` | `null` | no |
| <a name="input_set"></a> [set](#input\_set) | Custom values to be merged with the values | `map(string)` | `{}` | no |
| <a name="input_set_list"></a> [set\_list](#input\_set\_list) | Custom list values to be merged with the values | `map(list(string))` | `{}` | no |
| <a name="input_set_sensitive"></a> [set\_sensitive](#input\_set\_sensitive) | Custom sensitive values to be merged with the values | `map(string)` | `{}` | no |
| <a name="input_skip_crds"></a> [skip\_crds](#input\_skip\_crds) | If set, no CRDs will be installed. By default, CRDs are installed if not already present | `bool` | `false` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation. | `number` | `300` | no |
| <a name="input_upgrade_install"></a> [upgrade\_install](#input\_upgrade\_install) | The provider will install the release at the specified version even if a release not controlled by the provider is present: this is equivalent to running 'helm upgrade --install' with the Helm CLI. WARNING: this may not be suitable for production use | `bool` | `true` | no |
| <a name="input_values"></a> [values](#input\_values) | List of values in raw yaml format to pass to helm | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_manifest"></a> [manifest](#output\_manifest) | The full YAML manifest generated for this Helm release |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Helm release metadata |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace into which this Helm release was deployed. Included for convenience: depending on this output will wait until the release is present. |
| <a name="output_status"></a> [status](#output\_status) | Helm release status |
<!-- END_TF_DOCS -->