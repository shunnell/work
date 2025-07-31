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
      # TODO for now, IVA is given access to "shared" NPM and maven repositories, but that will change in the future
      #  when we create per-tenant repositories.
      "arn:aws:codeartifact:*:*:repository/platform-infra-repo/npm-store",
      "arn:aws:codeartifact:*:*:repository/platform-infra-repo/maven-central-store",
    ]
    push         = []
    pull_through = []
  }
}
