include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team_repositories" {
  path = "${get_repo_root()}/_envcommon/platform/ecr/team_repositories.hcl"
}

inputs = {
  legacy_ecr_repository_names_to_be_migrated = [
    "data-platform/docker/library/alpine-aws-cli-maven",
    "data-platform/docker/library/alpine-aws-cli-maven-enhanced",
    "data-platform/emedical-service",
    "data-platform/hello-world-service",
    "data-platform/ident-service",
    "data-platform/name-check-service",
    "data-platform/remote-data-collection-service",
    "data-platform/springboot-app-template",
    "data-platform/springboot-kafka-poc",
  ]
}