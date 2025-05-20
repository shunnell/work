# Wiz support

The Wiz cloud product requires integration with AWS environment which it scans. 

Cloud City is an oddball Wiz customer, in that we run commercial (non GovCloud) AWS, where most of Wiz's integration recommendations apply to connecting GovCloud accounts, which is done within Wiz using a separate mechanism.

This poses several difficulties for integrating Wiz with BESPIN:

1. Connecting commercial accounts at this time requires a static IAM user to exist in the "parent" (AWS Organizations root) account--a user without MFA, and with a static key/secret which are supplied to the Wiz backend. "Ordinary" GovCloud integration strategies do not require a static IAM user and instead only require creating an IAM role which trusts an external Wiz IAM principal, no credentials needed.
2. Wiz knows that this is a bummer integration strategy. As a result, they did *too* good a job fast-tracking a fix for it, and rolled out a prototype no-IAM-user-required release for Commercial<->Wiz integrators ... which broke. As a result, Wiz's documentation on how to integrate Commercial AWS with Wiz is inaccurate.
3. Wiz provides CloudFormation instructions for integrating Commercial AWS, and Terraform code for integrating GovCloud. Since both are wrong, this module represents BESPIN's *reimplementation* of the Wiz connector system, inspired by but not truly forked from their Terraform code for GovCloud integration, available [here](https://wizio-public-fedramp.s3-us-gov-west-1.amazonaws.com/deployment-v2/aws/wiz-aws-native-terraform-terraform-module.zip).
    - We (ZB, unilaterally) opted *not* to use their CloudFormation, since it has its own problems (perpetual drift, doesn't delete principals or policies when they're no longer needed), and that practice should continue: even if Wiz is a "CloudFormation first, Terraform second" company, combining CF and TF in Cloud City is a recipe for trouble--we know that from our use of CF with AWS Account Factory, which causes plenty of "dual AWS config management tool" hassles.
4. Their Terraform is also ... not great. It has defects, unnecessary bits, and hits policy length limits in Cloud City, so fairly extensive modifications have been made to it.
    - At some point in the future, Wiz will release a Terraform module that works for AWS Commercial<->Wiz integrations. We *might* be able to switch to that once it's available, but if it has the same code quality issues/bugs that their GovCloud integration package had, we might have to continue adapting its contents into our Terraform as is done here.
    - On the bright side, their Terraform/CloudFormation doesn't do anything too weird: it creates some IAM principals (roles and an IAM user in the master account) and attaches a bunch of policies to those, so it's not too hard to maintain an equivalent of it. Just **note well** that future Wiz permissions/TF changes may need to be incorporated into the code in this module, and that updates may not come "for free" unless this module's implementation is switched to use a (tested to be non-defective) upstream implementation from Wiz if or when that becomes available.
5. As of 5/15/2025, this module is *still* insufficient to connect Wiz to Cloud City. Wiz is working on fixing their backend so that either an external role-assuming principal or a static IAM user can connect to Cloud City's AWS. Until they have a crisp answer as to which should be used and when, this module tries to support both modes of access, so that hopefully fixing things once Wiz tells us what to do is as simple as deleting the parts that aren't requested.
    - Even if Wiz eventually provides a role-based system, if they instead implement a *near-term* fix that requires a static IAM user, the parts of this module that support an external role assumer principal *should be left in place*, so that we can easily switch to a role-based, IAM-user-less system whenever Wiz implements that. Short version is: 1) Wiz is fully broken now; 2) Wiz will implement a short term fix that requires an IAM user eventually; 3) Wiz will implement a long term enhancement that removes the need for that user and uses an external role trust instead; 4) therefore, we should suport both until the long term fix is available.

## What's in this module

Wiz integration is more or less exclusively a bunch of IAM permissions:
1. IAM policies in every Wiz-scannable AWS account in the organization that grant access (mostly read, but some write as well, e.g. for snapshot creation and EKS access entry creation) to AWS resources.
2. A predictably, uniformly-named role in each AWS account with those policies.
3. An IAM user in the organizations root account which can assume that role.
4. A trust policy on that role for eventual direct assumption by Wiz's external principal (see bullet 5 above).

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
| <a name="module_wiz_role"></a> [wiz\_role](#module\_wiz\_role) | ../iam/role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.wiz_cloud_cost_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_defend_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_full_policy_0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_full_policy_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_full_policy_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_lightsail_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_policy_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_policy_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.wiz_terraform_scanning_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.wiz_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.wiz_user_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.wiz_role_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.wiz_user_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_principals"></a> [assume\_role\_principals](#input\_assume\_role\_principals) | IAM principals (in addition to any static IAM user/role principals created inside this module) that can assume the Wiz role(s) created in this module. Assuming principals must authenticate via 'external\_id' in order to assume the Wiz role(s). | `set(string)` | `[]` | no |
| <a name="input_cloud-cost-scanning"></a> [cloud-cost-scanning](#input\_cloud-cost-scanning) | Enable Cloud Cost scanning | `bool` | `true` | no |
| <a name="input_data-scanning"></a> [data-scanning](#input\_data-scanning) | Enable DSPM data scanning | `bool` | `false` | no |
| <a name="input_eks-scanning"></a> [eks-scanning](#input\_eks-scanning) | Enable EKS scanning | `bool` | `false` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | Connector External ID | `string` | n/a | yes |
| <a name="input_lightsail-scanning"></a> [lightsail-scanning](#input\_lightsail-scanning) | Enable Lightsail scanning | `bool` | `false` | no |
| <a name="input_master_account_id"></a> [master\_account\_id](#input\_master\_account\_id) | AWS Account ID of the account which will contain the static IAM user used (temporarily, pending Wiz's resolution of Gov/Commercial integration defects) by Wiz actual | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_terraform-bucket-scanning"></a> [terraform-bucket-scanning](#input\_terraform-bucket-scanning) | Enable Terraform Bucket scanning | `bool` | `true` | no |
| <a name="input_wiz-defend-awslogs-policy"></a> [wiz-defend-awslogs-policy](#input\_wiz-defend-awslogs-policy) | (Optional) Enable Wiz Defend AWS Logs policy | `bool` | `true` | no |
| <a name="input_wiz-defend-rds-policy"></a> [wiz-defend-rds-policy](#input\_wiz-defend-rds-policy) | (Optional) Enable Wiz Defend RDS policy | `bool` | `true` | no |
| <a name="input_wiz-defend-s3-kms-policy"></a> [wiz-defend-s3-kms-policy](#input\_wiz-defend-s3-kms-policy) | (Optional) Enable Wiz Defend S3 KMS policy | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Wiz Access Role ARN |
| <a name="output_user_arn"></a> [user\_arn](#output\_user\_arn) | Wiz Access User ARN |
<!-- END_TF_DOCS -->