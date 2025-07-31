# `iam/fragments`

This file exists as a "library" of IAM snippets that are useful for multiple pieces of Cloud City IAM-related code.

This module is unusual compared to other Terraform modules in this repo:
1. It manages no AWS resources.
2. Unlike other modules, it is expected that this module will be be instantiated *multiple* times per 
   Terraform/Terragrunt invocation, rather than being used as a Terragrunt dependency. In other words, **do not pass 
   this module's outputs around via Terragrunt dependencies, and instead instantiate it in the Terraform code where 
   those dependencies are to be used.**

Its outputs are JSON documents corresponding to IAM policy "fragments": sections or snippets that are to be used in
other IAM policies. To use such a fragment, use the "inheritance" functionality of the `aws_iam_policy_document` data
source, like this:

```terraform
module "iam_fragments" {
  source = "../../iam/fragments"
}

data "aws_iam_policy_document" "mypolicy" {
  source_policy_documents = [module.iam_fragments.some_fragment]
  statement {
    ... # Other policy code goes here, "overlayed" on the fragment(s) provided by this module.
  }
}
```

# Making changes to this module

This module serves a special purpose as a "library of common snippets". As a result, certain things should never be
added to this module:

1. **Never** add variables to this module which configure its behavior on a per-tenant basis. Variables in general
   should only be added to this module in rare circumstances. Since this module is invoked from many places and for many
   different accounts, causing different invocations to behave differently risks creating security issues (e.g. by
   mistakenly giving one account's tenants permissions to take action as other tenants).
2. **Never** add entities to this module that modify AWS resources. Since this module is intended to be invoked from 
   many different places as a "library of constants", it should never change/manage AWS resources.
   This module should contain only:
    - `aws_iam_policy_document` data variables (which don't read from AWS, they just describe a JSON entity)/
    - Data variables which read from AWS, where necessary to create `aws_iam_policy_document` entities.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_restrictions"></a> [ec2\_restrictions](#module\_ec2\_restrictions) | ../modified_policy_document | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document._ec2_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.general_services_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.general_services_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.no_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_development_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_ec2_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_eks_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_eks_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_iam_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_iam_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_security_restrictions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disabled_services_restrictions"></a> [disabled\_services\_restrictions](#output\_disabled\_services\_restrictions) | n/a |
| <a name="output_iam_restrictions"></a> [iam\_restrictions](#output\_iam\_restrictions) | n/a |
| <a name="output_kms_decrypt_restrictions"></a> [kms\_decrypt\_restrictions](#output\_kms\_decrypt\_restrictions) | Fragment describing restrictions on KMS decryption actions; policies which contain kms:Decrypt* without this fragment will generate security findings |
| <a name="output_tenant_development_permissions"></a> [tenant\_development\_permissions](#output\_tenant\_development\_permissions) | Fragment describing permissions of actions tenant principals (Appropriate SSO users and tenant-created roles) are allowed to perform.<br/>    **Note:** Do *NOT* attach this document to any IAM principal that is not also subject to the various tenant restrictions IAM documents exported by this module (e.g. via a permissions boundary or SCP).<br/>    **Note:** These permissions are insufficient on their own to allow tenant principals to do most tasks. These permissions should generally be combined with a broader permissions policy (e.g. ReadOnlyAccess) to allow convenient use. |
| <a name="output_tenant_ec2_restrictions"></a> [tenant\_ec2\_restrictions](#output\_tenant\_ec2\_restrictions) | n/a |
| <a name="output_tenant_eks_restrictions"></a> [tenant\_eks\_restrictions](#output\_tenant\_eks\_restrictions) | n/a |
| <a name="output_tenant_iam_restrictions"></a> [tenant\_iam\_restrictions](#output\_tenant\_iam\_restrictions) | n/a |
| <a name="output_tenant_security_restrictions"></a> [tenant\_security\_restrictions](#output\_tenant\_security\_restrictions) | n/a |
| <a name="output_zero_access"></a> [zero\_access](#output\_zero\_access) | IAM policy document which disallows all actions on all resources, included for convenience |
<!-- END_TF_DOCS -->