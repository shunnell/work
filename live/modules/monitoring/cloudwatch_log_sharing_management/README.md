<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_monitoring_account_can_list_accounts"></a> [monitoring\_account\_can\_list\_accounts](#module\_monitoring\_account\_can\_list\_accounts) | ../../iam/policy | n/a |
| <a name="module_orgwide_sharing_role"></a> [orgwide\_sharing\_role](#module\_orgwide\_sharing\_role) | ../../iam/role | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_monitoring_account_id"></a> [monitoring\_account\_id](#input\_monitoring\_account\_id) | Account ID of the log management account (not the org master account where this module should be applied) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->