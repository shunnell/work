### Connecting Cloud City IaC to a brand new AWS account

This is very rarely done; seek help if you are invoking this process and not certain of what you're doing.

Account roles and policies need to be created for cross-account management through a pipeline.  Create these resources from a "local" system for new or recreated accounts, then allow a pipeline to manage them after.

# 1. Prerequisites

1. Ensure the account has been [successfully provisioned via Control Tower/Account Factory](https://confluence.fan.gov/display/CCPL/New+AWS+Account+Creation).
1. Ensure you can use the AWS console to log into the new AWS account as `AWSAdministratorAccess` or `Cloud_City_Admin` (even if things are broken once logged in) via SSO. If you cannot, the person who provisioned the accout in Control Tower will have to add you manually.
1. Ensure you have completed the [setup steps](setup.md) for this repo and its adjacent `modules`.
1. Per the [setup docs](setup.md), ensure `bespinctl` is installed/updated, and ensure that `live` and `modules` are both pulled to fresh `main` branches.

# 2. Platform team SSO access configuration

These steps configure Platform team SSO access to the account.
They do not need the account's folder to exist in `live`; whether it does or not is irrelevant to these steps.

1. In `live`, go into `management/platform/sso/cloud_city/Cloud_City_Admin/group_account_assignments`.
1. Run `bespinctl iac terragrunt plan` and verify that the only proposed diffs are related to the new account (correct/troubleshoot any unexpected extraneous diffs).
1. Run `bespinctl iac terragrunt apply`.
1. In an incognito tab, go to the AWS account picker. Validate that your `Cloud_City_Admin` access is available everywhere.
1.  Provision the rest of the platform-team SSO entities: go into `management/platform/sso/cloud_city` and do a `bespinctl iac terragrunt run-all plan`.
1. Verify that the only proposed diffs are related to the new account (correct/troubleshoot any unexpected extraneous diffs).
1. Apply the rest of platform team's permissions to the account: run`bespinctl iac terragrunt run-all apply`.

# 3. Account folder setup

These steps set up the bare minimum IaC management code files to manage the new AWS account (granting access to the account via SSO is handled by other sections in this document and does not require or interact with these steps).

1. Create a top-level folder in this repo named after the account, lower case (e.g. OCAM -> `ocam`).
1. In that folder, make an `account.hcl` with the `account` and `account_id` fields updated to match the folder name and the new account's AWS account ID, respectively.
1. Copy into `[ACCOUNT_NAME]/platform/common` from a similar account to new account's folder. In other words, for a new account `foobar`, there should now exist `foobar/platform/common/account/terragrunt.hcl` and sundry.
1. Copy into `[ACCOUNT_NAME]/platform/team.hcl` from a similar account to the new account's folder. Check the contents of `team.hcl` and make sure nothing in there refers to the account you copied from (most do not).
1. Check these changes into a new merge request, e.g. `CCP-###: Baseline IaC configuration for new account [ACCOUNT_NAME] [ACCOUNT_ID]`.
1. Get approval or review on that MR as needed before proceeding (though subsequent steps are low-risk since they only affect an account that is not yet in use; this process is up to you). Regardless, **this MR should not be merged until all steps in this document are complete.**

# 4. Bootstrap `terragrunter` user in new account

These steps run a special terragrunt operation to provision just the `terragrunter` user and policy in the new account, without relying on `terragrunter` existing, and without using any stored Terraform state in S3.

1. In the root of `live`, run: `bespinctl clear-caches --execute`. Resolve errors and/or `sudo` if necessary until it reports success. This will update stored account lists/credential caches needed for the next steps.
1. In any folder in `live`, do `bespinctl iac bootstrap-new-aws-account --account [ACCOUNT_ID] plan`.
1. Validate that the outputted terraform plan will create a `terragrunter` user in the new account, and has no errors or modifications/destructions proposed.
1. In any folder in `live`, do `bespinctl iac bootstrap-new-aws-account --account [ACCOUNT_ID] apply`.
1. In `[ACCOUNT_NAME]/platform/common/terragrunter`, run `bespinctl iac terragrunt import 'module.terragrunter_role.aws_iam_role.this' 'terragrunter'`.
1. In `[ACCOUNT_NAME]/platform/common/terragrunter`, run `bespinctl iac terragrunt import 'module.terragrunter_policy.aws_iam_policy.this' 'arn:aws:iam::[ACCOUNT_ID]:policy/terragrunter'`.
1. In `[ACCOUNT_NAME]/platform/common/terragrunter`, run `bespinctl iac terragrunt apply` and verify that all changes proposed (if any) are only to tags.

# 5. Apply account baseline configuration and final cleanup

1. Add an entry to the `.account_groups` GitLab template in [.gitlab-ci.yml](../.gitlab-ci.yml) with the same value as the `[ACCOUNT_NAME]`; as well as the associated subdirectory in [infra](../infra) and [management](../management).
1. Plan and apply all IaC in `[ACCOUNT_NAME]/platform/common`. 
    - This will do a lot, and will take awhile. It's also not uncommon for "cold start" issues to be discovered here: cases where the complex code in `common` broke previously in ways that only become evident when applying it to a brand new account. Some fixes may be necessary.
1. (optional) to ensure that SSO-related stuff beyond the platform team's access is fully configured, plan and apply all IaC in the `management/` top-level folder. This may take a very long time.
1. Log into the management AWS account's web console, and navigate to "IAM Identity Center" -> "Permission Sets".
1. In any folder in `live`, run `bespinctl aws iam list-direct-account-assignments`
1. In the management web console, for any users mentioned in the output of that command that are members of the newly-created account, remove their per-user access (they should only be given access via groups). That can be done by opening the permission set named in the `list-direct-account-assignments` output in the web UI, finding the user in question by name in the "Users and Groups" tab, and selecting "Remove Access".
    - Make sure to only do this once Platform Team SSO has been set up (heading number 2 above), otherwise you run the risk of removing all access to an account without another way in!
    - Only remove your own user access once you're very sure that at least one other similarly-permissioned member of the platform team who is *not* listed in the `list-direct-account-assignments` output can log into the new account.
1. Get approval for and merge all MRs related to this baseline account provisioning.
1. Create additional MRs and/or JIRA stories to set up needed resources in the new account (e.g. VPCs, EKS clusters, tenant SSO groups, and the like).
