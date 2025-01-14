include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "."
}

dependency "substrate" {
  config_path = "../kubernetes_cluster"
  mock_outputs = {
    eks_cluster = {
      name     = "mock_cluster"
      endpoint = "123.123.123.123"
      certificate_authority = [{
        data = "YXNvdGh1c29odG9zdWhvc2F0aHVzb2F0dWhvc3V0aGFvc3R1aGE="
      }]
    }
    cache_s3_bucket_name            = "mock_bucket"
    runner_service_account_role_arn = "aws:iam:arn::111111111111:role/mock"
  }
}

inputs = {
  runner_eks_cluster_name         = dependency.substrate.outputs.eks_cluster.name
  runner_service_account_role_arn = dependency.substrate.outputs.runner_service_account_role_arn,
  cache_s3_bucket_name            = dependency.substrate.outputs.cache_s3_bucket_name,
  runner_cluster_endpoint         = dependency.substrate.outputs.eks_cluster.endpoint,
  runner_cluster_ca_data          = dependency.substrate.outputs.eks_cluster.certificate_authority[0].data


  #
  # runner_eks_cluster_name         = "dos_gitlab_central_runner_cluster"
  # runner_service_account_role_arn = "arn:aws:iam::381492150796:role/gitlab-runner-sa-role"
}
