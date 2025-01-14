# Root terragrunt.hcl
locals {
  # Parse the path to get environment, region, etc.
  path_parts = split("/", path_relative_to_include())

  # Common tags for all resources
  common_tags = {
    ManagedBy = "Terragrunt"
    Project   = "CloudCity"
  }

  # Default AWS region for all resources
  default_region = "us-east-1"

  account               = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  terragrunter_role_arn = "${local.account.locals.terragrunter_role_arn}"
}

# Remote state configuration
remote_state {
  backend = "s3"
  config = {
    bucket         = "dos-cloudcity-infra-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.default_region
    encrypt        = true
    dynamodb_table = "dos-cloudcity-infra-terraform-locks"
    assume_role = {
      role_arn = "arn:aws:iam::381492150796:role/terragrunter"
    }
    # first time only
    # profile = "infra"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  # begin template
  contents = <<EOF
provider "aws" {
  region = "${local.default_region}"
  assume_role {
    role_arn = "${local.terragrunter_role_arn}"
  }
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
  # end template
}
