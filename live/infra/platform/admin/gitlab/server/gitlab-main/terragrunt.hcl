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
  config_path = "../../../sandbox" # TO DO should be migrated to admin_eks
  mock_outputs = {
    cluster_name = "name"
  }
}

dependency "rds" {
  config_path = "../database"
  mock_outputs = {
    aurora_serverless_master_user_secret_name = ["name"]
    aurora_serverless_v2_cluster_master_user_secret = [{
      secret_arn = "arn:fake:fake"
    }]
    aurora_serverless_v2_cluster_instances = {
      one = {
        endpoint = "rds-endpoint"
      }
    }
  }
}

dependency "redis" {
  config_path = "../cache"
  mock_outputs = {
    secret_name                    = "name"
    secret_arn                     = "arn:redis"
    configuration_endpoint_address = "redis-endpoint"
    primary_endpoint_address       = "primary"
  }
}

dependency "irsa_role" {
  config_path = "../object_storage/irsa"
  mock_outputs = {
    iam_role_arn = "role-arn"
  }
}

dependency "s3_buckets" {
  config_path = "../object_storage/s3"
  mock_outputs = {
    buckets = [
      {
        "${local.prefix}-artifacts-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-ci-secure-files-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-dependency-proxy-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-lfs-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-mr-diffs-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-packages-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-pages-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-terraform-state-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-uploads-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-backup-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        },
        "${local.prefix}-tmp-backup-${local.suffix}" = {
          bucket_id = "mock-bucket-id"
        }
      }
    ]
  }
}

inputs = {
  gitlab_domain    = "${local.suffix}.cloud-city" ## TO DO: Change this to the actual domain when running in prod
  gitlab_namespace = local.namespace
  cluster_name     = dependency.cluster.outputs.cluster_name
  release_name     = "gitlab"
  chart_version    = "8.3.1"
  secret_arn = [
    dependency.rds.outputs.aurora_serverless_v2_cluster_master_user_secret[0].secret_arn,
    dependency.redis.outputs.secret_arn
  ]
  rds_aws_secret           = dependency.rds.outputs.aurora_serverless_master_user_secret_name[0]
  redis_aws_secret         = dependency.redis.outputs.secret_name
  acm_cert_arn             = "arn:aws:acm:us-east-1:381492150796:certificate/c6a17e29-7365-4e3a-9070-9bb5956d8d59"
  rds_endpoint             = dependency.rds.outputs.aurora_serverless_v2_cluster_instances["one"].endpoint
  redis_endpoint           = dependency.redis.outputs.primary_endpoint_address
  irsa_role                = dependency.irsa_role.outputs.iam_role_arn
  artifacts_bucket         = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-artifacts-${local.suffix}"].bucket_id
  ci_secure_bucket         = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-ci-secure-files-${local.suffix}"].bucket_id
  dependency_proxy_bucket  = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-dependency-proxy-${local.suffix}"].bucket_id
  mr_diffs_bucket          = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-mr-diffs-${local.suffix}"].bucket_id
  gitlab_lfs_bucket        = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-lfs-${local.suffix}"].bucket_id
  gitlab_pkg_bucket        = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-packages-${local.suffix}"].bucket_id
  tf_state_bucket          = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-terraform-state-${local.suffix}"].bucket_id
  gitlab_uploads_bucket    = dependency.s3_buckets.outputs.buckets[0]["${local.prefix}-uploads-${local.suffix}"].bucket_id
  gitlab_backup_bucket     = dependency.s3_buckets.outputs.buckets[0]["${include.gitlab_config.locals.prefix}-backup-${local.suffix}"].bucket_id
  gitlab_tmp_backup_bucket = dependency.s3_buckets.outputs.buckets[0]["${include.gitlab_config.locals.prefix}-tmp-backup-${local.suffix}"].bucket_id

}