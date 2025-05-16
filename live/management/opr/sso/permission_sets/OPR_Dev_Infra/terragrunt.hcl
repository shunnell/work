include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

include "infra_permission_set" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/tenant_infra_permission_set.hcl"
}

inputs = {
  tenant_subgroup_name = "Dev"
  allow_code_artifact_repositories = {
    pull = [
      # TODO for now, OPR3 is given broad pull permissions for everything. Future platform architecture design around
      #   supply chain security should result in this access scope being narrowed.
      "arn:aws:codeartifact:*:*:repository/platform-infra-repo/npm-store",
      "arn:aws:codeartifact:*:*:repository/platform-infra-repo/pypi-store",
      # TODO remove access to platform-infra-repository and eventually remove the repository itself
      "arn:aws:codeartifact:*:*:repository/platform-infra-repo/platform-infra-repository"
    ]
    push         = []
    pull_through = []
  }
} 