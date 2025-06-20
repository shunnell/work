<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cache_auth_token"></a> [cache\_auth\_token](#module\_cache\_auth\_token) | ../secret | n/a |
| <a name="module_engine_logs"></a> [engine\_logs](#module\_engine\_logs) | ../monitoring/cloudwatch_log_group | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ../network/security_group | n/a |
| <a name="module_shipping"></a> [shipping](#module\_shipping) | ../monitoring/cloudwatch_log_shipping_source | n/a |
| <a name="module_slow_logs"></a> [slow\_logs](#module\_slow\_logs) | ../monitoring/cloudwatch_log_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_secretsmanager_secret_version.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | User-created description for the replication group. Must not be empty. | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | The cache engine (redis, valkey, memcached) | `string` | `"redis"` | no |
| <a name="input_logs_destination_arn"></a> [logs\_destination\_arn](#input\_logs\_destination\_arn) | Destination ARN for CloudWatch logs | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the cache | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The instance class used. | `string` | `"cache.m7g.xlarge"` | no |
| <a name="input_num_cache_clusters"></a> [num\_cache\_clusters](#input\_num\_cache\_clusters) | Number of cache clusters | `number` | `2` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Refer to 'network/security\_group' for input details | `map(any)` | `{}` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | Maximum number of snapshots to retain | `number` | `1` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC Subnet IDs for the cache subnet group | `set(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to the cache | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC this will be in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the created ElastiCache Replication Group. |
| <a name="output_configuration_endpoint_address"></a> [configuration\_endpoint\_address](#output\_configuration\_endpoint\_address) | Address of the replication group configuration endpoint |
| <a name="output_engine_version_actual"></a> [engine\_version\_actual](#output\_engine\_version\_actual) | Because ElastiCache pulls the latest minor or patch for a version, this attribute returns the running version of the cache engine. |
| <a name="output_id"></a> [id](#output\_id) | ID of the ElastiCache Replication Group. |
| <a name="output_member_clusters"></a> [member\_clusters](#output\_member\_clusters) | Identifiers of all the nodes that are part of this replication group. |
| <a name="output_primary_endpoint_address"></a> [primary\_endpoint\_address](#output\_primary\_endpoint\_address) | Address of the replication group primary cache endpoint |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the secret containing the auth token |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | ID of the secret containing the auth token |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group. |
<!-- END_TF_DOCS -->