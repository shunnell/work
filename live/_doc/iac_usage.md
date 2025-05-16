# Using Terragrunt to make IaC Changes in Cloud City

This doc discusses the basics of how to make changes.

Before you read it, make sure you are [set up](./setup.md) and have familiarized yourself with the [organization of files](./iac_organization.md) in the repo.

# Dangerous things to avoid

First, some things to watch out for:

- **Do not add `profile =` to `root.hcl` in order to run Terragrunt.** If you find that you cannot plan/apply without setting a `profile` in `root.hcl`, that issue needs to be fixed in either your [local setup](./setup.md) or by changing the Terragrunter role's IAM permissions.
- **Never invoke `terraform` directly.** We only use terraform via `terragrunt`; using Terraform directly will fail and/or break things.
- **Never plan/apply Terragrunt in a directory without a `terragrunt.hcl` file.** If you are doing this, you have made a wrong turn somewhere.
- **Only plan/apply Terragrunt in a directory whose `terragrunt.hcl` file contains an `include` block pointing at `root.hcl`**, like this:
    ```terraform
    include "root" {
      path = find_in_parent_folders("root.hcl")
    }
    ```
- **If not using `bespinctl`, only plan/apply Terragrunt if you are assumed into the *infra* account's `terragrunter` role!** 
  - `aws sts get-caller-identity` *must* report that you are assumed into the `arn:aws:iam::381492150796:role/terragrunter` role, otherwise you may destroy/alter infrastructure in the wrong AWS account!
  - Being the `terragrunter` role in an account other than `381492150796` is bad! No matter what account you're changing, you always run as `381492150796/terragrunter`, every time, no exceptions.
  - Being `AdministratorAccess` or similar and hand-editing `root.hcl` to allow that credential is no longer supported as it is very risky and not needed. Assume the infra account's `terragrunter` role instead and everything works without hand-editing `root.hcl`.
- **Never plan/apply Terragrunt in a directory whose `terragrunt.hcl` does not contain or `include` a `terraform {}` block**. Doing this creates incorrect Terraform files which are easy to accidentally check in.
- **Be very careful when moving `.hcl` files that manage existing infrastructure around.** The path to a `.hcl` file determines where the Terraform state is stored; see [here](./iac_organization.md) for details.

Many/most of these things are prevented automatically if you use `bespinctl iac terragrunt` instead of using `terragrunt` manually.

# Preparing your first change

1. Ensure that the `live` and `modules` repos are updated on the branch of your choice.
2. Make the changes you need in the appropriate Terragrunt/Terraform code files in either of the two repos.
3. `cd` into the top-level AWS account and subfolder containing the `terragrunt.hcl` file which contains or invokes code which contains your changes.
4. Run `bespinctl iac terragrunt run-all init`. This is not necessary every time, but is harmless and a good sanity-check to make sure your code and sign-in status are in good shape.
    - If `init` fails, troubleshoot or get help.
5. Once `init` is successful, run `bespinctl iac terragrunt plan` (or `run-all plan` if you need to alter multiple resources). Ensure the plan succeeds and contains proposed resource change statements that you would expect given the scope of the task you're working on.
6. Debug/iterate as appropriate until `plan` returns the output you expect.
7. Get approval for your code change(s) by submitting MRs to the `live` and/or `modules` repos.
    - To demonstrate that your code works appropriately, attach the `plan` output from your latest changes to any MRs you write, so that your reviewers can see what would be changed.
8. Once your changes are approved, merge to `main` and then (in the same directory under `live` as before), do `bespinctl iac terragrunt apply` (`run-all apply` should be used with caution as it does not prompt for confirmation as often).
9. Do `bespinctl iac terragrunt apply` again and make sure your plan is "stable"--that is, it does not propose changes each time. 
10. Perform any manual testing or test plans from the task you are working on and verify that your changes were made as appropriate.
11. Congratulations, you're done! Close any Jira entities related to the work you completed.


If the change you are working on is *highly urgent*, you can get a second engineer's eyes on the proposed plan and `apply` it right away. However, that's dangerous (due to merge conflicts and stepping on each others changes) and should be avoided wherever possible.
Wherever possible, prefer the more rigorous process above.

# Other Useful Commands

Validate HCL:
```bash
terragrunt hclvalidate --strict-mode
```

Validate inputs:
```bash
terragrunt run-all validate-inputs --terragrunt-strict-validate
```

Format HCL:
```bash
terragrunt hclfmt
```

Apply changes to all services in an environment (**Use with immense care; this is a very easy way to `rm -rf /` all our AWS resources**):
```bash
cd dev
terragrunt run-all apply --terragrunt-no-auto-init --terragrunt-parallelism 3 --strict-mode --terragrunt-provider-cache
```

Destroy a specific service:
```bash
cd dev/s3
terragrunt run-all destroy --terragrunt-no-auto-init --terragrunt-parallelism 3 --strict-mode --terragrunt-provider-cache
```

## Troubleshooting

Common issues:

1. State Lock Issues
    ```bash
    terragrunt force-unlock <LOCK_ID>
    ```

1. Initialization Failures
    ```bash
    terragrunt run-all init --reconfigure --terragrunt-no-auto-init --terragrunt-parallelism 3 --strict-mode --terragrunt-provider-cache
    ```

Other:

1. Clear terraform cache:
   ```bash
   find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
   find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
   ```
