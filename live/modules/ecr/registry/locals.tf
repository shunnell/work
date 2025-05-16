data "aws_caller_identity" "ecr_account" {}

data "aws_region" "ecr_region" {}

locals {
  pull_through_secrets = toset(["github", "docker", "registry.gitlab.com"])
  pull_through_upstreams = {
    docker_hub = {
      ecr_repository_prefix = "docker-hub",
      upstream_registry_url = "registry-1.docker.io",
      credential_arn        = module.pull_through_secrets["docker"].secret_arn
    },
    ecr_public = {
      ecr_repository_prefix = "ecr-public",
      upstream_registry_url = "public.ecr.aws",
      credential_arn        = null
    },
    github = {
      ecr_repository_prefix = "github",
      upstream_registry_url = "ghcr.io",
      credential_arn        = module.pull_through_secrets["github"].secret_arn
    },
    gitlab = {
      ecr_repository_prefix = "gitlab",
      upstream_registry_url = "registry.gitlab.com",
      credential_arn        = module.pull_through_secrets["registry.gitlab.com"].secret_arn
    },
    k8s = {
      ecr_repository_prefix = "k8s",
      upstream_registry_url = "registry.k8s.io",
      credential_arn        = null
    },
    quay = {
      ecr_repository_prefix = "quay",
      upstream_registry_url = "quay.io",
      credential_arn        = null
    },
  }
}
