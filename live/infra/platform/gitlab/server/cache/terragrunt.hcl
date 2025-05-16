include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../../../network/gitlab_vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/elasticache"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

dependency "cluster" {
  config_path = "../../eks_cluster"
  mock_outputs = {
    cluster_security_group_id = ""
  }
}

terraform {
  source = "${get_repo_root()}/../modules//elasticache"
}

inputs = {
  name                 = "${include.gitlab_config.locals.prefix}-cache"
  description          = "Cache for GitLab server."
  logs_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  vpc_id               = dependency.vpc.outputs.vpc_id
  subnet_ids           = [for k, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  security_group_rules = {
    eks_gitlab_cache_traffic = {
      protocol = "tcp"
      type     = "egress"
      ports    = [0]
      target   = dependency.cluster.outputs.cluster_security_group_id
    }
  }
}
