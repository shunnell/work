# `modified_policy_document`

This module represents transformations and best-practices restrictions applied to an IAM policy document, of the kind
provided by the `aws_iam_policy_document` Terraform data variable.

It manages no resources and functions as a "pure function" returning a modified version of that same policy document.

The outputted policy JSON is **minified** to avoid length limits.

It provides two pieces of functionality: validations and transformations.

## Validations

It's a miserable experience to craft an IAM policy document that `plan`s but fails to `apply` due to AWS-imposed 
restrictions on length or content. In service to avoiding that, this module can be configured to validate various things
about a policy:

1. Whether or not all statements in the policy are `Allow` or `Deny` via the `require_effect` variable (set to `null` 
   to disable).
2. The maximum length of the policy, to avoid apply-time errors due to AWS document length limits.
3. Whether or not all statements in the policy have descriptive SIDs, via the `require_sid` variable.
4. (TODO/planned): Whether or not all statements in the policy have "vendor" components on their resources, via the 
   `require_resource_vendor` variable.

## Transformations

This module can apply transformations to supplied policy documents as well. The following transformations are supported:

1. Uniform conditions can be added to all `statement`s in the policy via the `add_conditions_to_all_stanzas`. These
   conditions will not replace existing conditions, just add to them.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_conditions_to_all_stanzas"></a> [add\_conditions\_to\_all\_stanzas](#input\_add\_conditions\_to\_all\_stanzas) | Conditions to append to all 'statement's in 'policies' | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = set(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_max_length"></a> [max\_length](#input\_max\_length) | Require the output policy's minified JSON to be shorter than this value | `number` | `16000` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Set of policy JSON documents to combine, transform, and validate into a single output policy | `set(string)` | n/a | yes |
| <a name="input_require_effect"></a> [require\_effect](#input\_require\_effect) | If non-null, require all statements in the policy to have the same 'effect' | `string` | n/a | yes |
| <a name="input_require_sid"></a> [require\_sid](#input\_require\_sid) | If true, require all statements in 'policies' to have a 'Sid' key. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_json"></a> [json](#output\_json) | The modified, minified policy document JSON. |
| <a name="output_policy_length"></a> [policy\_length](#output\_policy\_length) | The length of `modified_policy` |
| <a name="output_policy_statements"></a> [policy\_statements](#output\_policy\_statements) | The list of 'statement' objects in the policy's underlying 'data.aws\_iam\_policy\_document' |
<!-- END_TF_DOCS -->