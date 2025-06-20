data "aws_caller_identity" "ecr_account" {}

data "aws_region" "ecr_region" {}

locals {
  # Map of pull-through upstream to secret name. Secret names are stored here so we don't have to replace or fuss
  # with/import some very old pre-existing secrets.
  pull_through_prefix_to_secret_name = {
    "docker"     = "docker",
    "ecr-public" = null,
    "github"     = "github",
    "gitlab"     = "registry.gitlab.com",
    "k8s"        = null,
    "quay"       = null,
  }
  repo_stem = "arn:aws:ecr:${data.aws_region.ecr_region.region}:${data.aws_caller_identity.ecr_account.account_id}:repository"
}
