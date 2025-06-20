<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora_serverless_v2"></a> [aurora\_serverless\_v2](#module\_aurora\_serverless\_v2) | terraform-aws-modules/rds-aurora/aws | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_db_name"></a> [cluster\_db\_name](#input\_cluster\_db\_name) | Name for an automatically created database on cluster creation | `string` | n/a | yes |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Create timeout configuration for the cluster | `string` | `"15m"` | no |
| <a name="input_db_cluster_identifier"></a> [db\_cluster\_identifier](#input\_db\_cluster\_identifier) | Unique identifier for the DB instance | `string` | n/a | yes |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Delete timeout configuration for the cluster | `string` | `"15m"` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql` | `list(string)` | <pre>[<br/>  "postgresql",<br/>  "instance",<br/>  "iam-db-auth-error"<br/>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine | `string` | `"aurora-postgresql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Database engine version | `string` | `"16.6"` | no |
| <a name="input_inbound_security_group_ids"></a> [inbound\_security\_group\_ids](#input\_inbound\_security\_group\_ids) | Security Group IDs to allow inbound traffic from | `map(string)` | `{}` | no |
| <a name="input_instance_names"></a> [instance\_names](#input\_instance\_names) | List of instance names. Represents number of instances | `list(string)` | <pre>[<br/>  "one"<br/>]</pre> | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database | `string` | n/a | yes |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum number of read replicas permitted when autoscaling is enabled | `number` | `10` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum number of read replicas permitted when autoscaling is enabled | `number` | `0` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections | `string` | `"5432"` | no |
| <a name="input_seconds_until_auto_pause"></a> [seconds\_until\_auto\_pause](#input\_seconds\_until\_auto\_pause) | n/a | `number` | `3600` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to apply to the RDS instance | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the RDS instance | `map(string)` | `{}` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | Update timeout configuration for the cluster | `string` | `"15m"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC this will belong to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aurora_serverless_master_user_secret_name"></a> [aurora\_serverless\_master\_user\_secret\_name](#output\_aurora\_serverless\_master\_user\_secret\_name) | The base name of the Secrets manager secret for the Aurora master user |
| <a name="output_aurora_serverless_v2_cluster_arn"></a> [aurora\_serverless\_v2\_cluster\_arn](#output\_aurora\_serverless\_v2\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_aurora_serverless_v2_cluster_database_name"></a> [aurora\_serverless\_v2\_cluster\_database\_name](#output\_aurora\_serverless\_v2\_cluster\_database\_name) | Name for an automatically created database on cluster creation |
| <a name="output_aurora_serverless_v2_cluster_endpoint"></a> [aurora\_serverless\_v2\_cluster\_endpoint](#output\_aurora\_serverless\_v2\_cluster\_endpoint) | Writer endpoint for the cluster |
| <a name="output_aurora_serverless_v2_cluster_engine_version_actual"></a> [aurora\_serverless\_v2\_cluster\_engine\_version\_actual](#output\_aurora\_serverless\_v2\_cluster\_engine\_version\_actual) | The running version of the cluster database |
| <a name="output_aurora_serverless_v2_cluster_hosted_zone_id"></a> [aurora\_serverless\_v2\_cluster\_hosted\_zone\_id](#output\_aurora\_serverless\_v2\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint |
| <a name="output_aurora_serverless_v2_cluster_id"></a> [aurora\_serverless\_v2\_cluster\_id](#output\_aurora\_serverless\_v2\_cluster\_id) | The RDS Cluster Identifier |
| <a name="output_aurora_serverless_v2_cluster_instances"></a> [aurora\_serverless\_v2\_cluster\_instances](#output\_aurora\_serverless\_v2\_cluster\_instances) | A map of cluster instances and their attributes |
| <a name="output_aurora_serverless_v2_cluster_master_user_secret"></a> [aurora\_serverless\_v2\_cluster\_master\_user\_secret](#output\_aurora\_serverless\_v2\_cluster\_master\_user\_secret) | The generated database master user secret when `manage_master_user_password` is set to `true`. Contains 'username' and 'password' |
| <a name="output_aurora_serverless_v2_cluster_master_username"></a> [aurora\_serverless\_v2\_cluster\_master\_username](#output\_aurora\_serverless\_v2\_cluster\_master\_username) | The database master username |
| <a name="output_aurora_serverless_v2_cluster_members"></a> [aurora\_serverless\_v2\_cluster\_members](#output\_aurora\_serverless\_v2\_cluster\_members) | List of RDS Instances that are a part of this cluster |
| <a name="output_aurora_serverless_v2_cluster_port"></a> [aurora\_serverless\_v2\_cluster\_port](#output\_aurora\_serverless\_v2\_cluster\_port) | The database port |
| <a name="output_aurora_serverless_v2_cluster_reader_endpoint"></a> [aurora\_serverless\_v2\_cluster\_reader\_endpoint](#output\_aurora\_serverless\_v2\_cluster\_reader\_endpoint) | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| <a name="output_aurora_serverless_v2_cluster_resource_id"></a> [aurora\_serverless\_v2\_cluster\_resource\_id](#output\_aurora\_serverless\_v2\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_aurora_serverless_v2_cluster_security_group_id"></a> [aurora\_serverless\_v2\_cluster\_security\_group\_id](#output\_aurora\_serverless\_v2\_cluster\_security\_group\_id) | The security group id for this db cluster |
| <a name="output_aurora_serverless_v2_db_subnet_group_name"></a> [aurora\_serverless\_v2\_db\_subnet\_group\_name](#output\_aurora\_serverless\_v2\_db\_subnet\_group\_name) | The db subnet group name |
<!-- END_TF_DOCS -->