include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "nexus_config" {
  path   = find_in_parent_folders("nexus_config.hcl")
  expose = true
}

include "k8s" {
  path = "${get_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

dependency "cluster" {
  config_path = "../../admin_eks"
  mock_outputs = {
    cluster_name = ""
  }
}

dependency "db" {
  config_path = "../database"
  mock_outputs = {
    aurora_serverless_master_user_secret_name = [""]
    aurora_serverless_v2_cluster_master_user_secret = [{
      secret_arn = ""
    }]
    aurora_serverless_v2_cluster_endpoint = ""
  }
}

terraform {
  source = "${get_repo_root()}/../modules//nexus"
}

inputs = {
  cluster_name       = dependency.cluster.outputs.cluster_name
  rds_aws_secret     = dependency.db.outputs.aurora_serverless_master_user_secret_name[0]
  license_secret_arn = include.nexus_config.locals.license_secret_arn
  secret_arn = [
    dependency.db.outputs.aurora_serverless_v2_cluster_master_user_secret[0].secret_arn,
    include.nexus_config.locals.license_secret_arn
  ]
  db_endpoint = dependency.db.outputs.aurora_serverless_v2_cluster_endpoint
}
