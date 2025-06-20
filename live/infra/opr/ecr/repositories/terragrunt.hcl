include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team_repositories" {
  path           = "${get_repo_root()}/_envcommon/platform/ecr/team_repositories.hcl"
  merge_strategy = "deep"
}

inputs = {
  aws_accounts_with_pull_access = [
    # OPR is the sole tenant with production presence at this time, so prod is added to the list of accounts that can
    # pull their images. NB: the "deep" merge strategy above results in this value being appended to the input variable
    # rather than replacing it.
    read_terragrunt_config("${get_repo_root()}/prod/account.hcl").locals.account_id
  ]
  legacy_ecr_repository_names_to_be_migrated = [
    "dos-ca-opr-v3-application-repo",
    "dos-ca-opr-v3-helm-chart",
    "dos-ca-opr-v3-job-runner-repo",
    "dos-ca-opr-v3-mock-apis-repo",
    "dos-ca-opr-v3-setup-ssl-certs-repo",
    "opr/application/opr-app-python",
    "cloud-city/dh/mcr.microsoft.com/playwright",
    "playwright",
  ]
}
