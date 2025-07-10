include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  prefix         = include.gitlab_config.locals.prefix
  suffix         = include.gitlab_config.locals.suffix
  namespace      = include.gitlab_config.locals.namespace
}

terraform {
  source = "${get_repo_root()}/../modules//gitlab/server"
}

dependency "cluster" {
  config_path = "../primary_gitlab_eks_cluster"
  mock_outputs = {
    cluster_name = ""
  }
}

dependency "rds" {
  config_path = "../database"
  mock_outputs = {
    aurora_serverless_master_user_secret_name = [""]
    aurora_serverless_v2_cluster_master_user_secret = [{
      secret_arn = ""
    }]
    aurora_serverless_v2_cluster_endpoint = ""
  }
}

dependency "redis" {
  config_path = "../cache"
  mock_outputs = {
    secret_name                    = ""
    secret_arn                     = ""
    configuration_endpoint_address = ""
    primary_endpoint_address       = ""
  }
}

dependency "irsa_role" {
  config_path = "../object_storage/irsa"
  mock_outputs = {
    iam_role_arn = ""
  }
}

dependency "s3_buckets" {
  config_path = "../object_storage/s3"
  mock_outputs = {
    buckets = [
      {
        "${local.prefix}-artifacts-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-ci-secure-files-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-dependency-proxy-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-lfs-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-mr-diffs-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-packages-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-registry-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-pages-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-terraform-state-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-uploads-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-backup-${local.suffix}" = {
          bucket_id = ""
        },
        "${local.prefix}-tmp-backup-${local.suffix}" = {
          bucket_id = ""
        }
      }
    ]
  }
}

dependency "secret" {
  config_path = "../secret"
  mock_outputs = {
    secret_id = ""
  }
}

inputs = {
  domain           = "gitlab.cloud-city"
  cluster_name     = dependency.cluster.outputs.cluster_name
  release_name     = "gitlab-${local.suffix}"
  chart_version    = "9.1.1"
  gitlab_secret_id = dependency.secret.outputs.secret_id
  secret_arn = [
    dependency.rds.outputs.aurora_serverless_v2_cluster_master_user_secret[0].secret_arn,
    dependency.redis.outputs.secret_arn
  ]
  rds_aws_secret          = dependency.rds.outputs.aurora_serverless_master_user_secret_name[0]
  redis_aws_secret        = dependency.redis.outputs.secret_name
  rds_endpoint            = dependency.rds.outputs.aurora_serverless_v2_cluster_endpoint
  redis_endpoint          = dependency.redis.outputs.primary_endpoint_address
  irsa_role               = dependency.irsa_role.outputs.iam_role_arn
  artifacts_bucket        = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-artifacts-${local.suffix}"].bucket_id
  ci_secure_bucket        = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-ci-secure-files-${local.suffix}"].bucket_id
  dependency_proxy_bucket = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-dependency-proxy-${local.suffix}"].bucket_id
  mr_diffs_bucket         = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-mr-diffs-${local.suffix}"].bucket_id
  lfs_bucket              = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-lfs-${local.suffix}"].bucket_id
  pkg_bucket              = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-packages-${local.suffix}"].bucket_id
  registry_bucket         = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-registry-${local.suffix}"].bucket_id
  pages_bucket            = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-pages-${local.suffix}"].bucket_id
  tf_state_bucket         = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-terraform-state-${local.suffix}"].bucket_id
  uploads_bucket          = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-uploads-${local.suffix}"].bucket_id
  backup_bucket           = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-backup-${local.suffix}"].bucket_id
  tmp_backup_bucket       = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-tmp-backup-${local.suffix}"].bucket_id
}
