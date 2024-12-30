# Root terragrunt.hcl
locals {
  # Parse the path to get environment, region, etc.
  path_parts = split("/", path_relative_to_include())

  # Common tags for all resources
  common_tags = {
    Environment = local.path_parts[0]
    ManagedBy   = "Terragrunt"
    Project     = "CloudCity"
  }
}

# Remote state configuration
remote_state {
  backend = "s3"
  config = {
    bucket         = "dos-cloudcity-infra-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dos-cloudcity-infra-terraform-locks"
    # First time (local) only
    # profile        = "infra"
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
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}
