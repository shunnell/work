# `iam/fragments`

This file exists as a "library" of IAM snippets that are useful for multiple pieces of Cloud City IAM-related code.

It creates no resources, and can be instantiated any number of times per Terraform/Terragrunt invocation.

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
```

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
| [aws_iam_policy_document.kms_decryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_decrypt_restrictions"></a> [kms\_decrypt\_restrictions](#output\_kms\_decrypt\_restrictions) | n/a |
<!-- END_TF_DOCS -->