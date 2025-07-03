include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

locals {
  suffix = include.gitlab_config.locals.suffix
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/elasticache"
  mock_outputs = {
    cloudwatch_destination_arn = ""
  }
}

dependency "vpc" {
  config_path = "../../network/gitlab_vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cluster" {
  config_path = "../primary_gitlab_eks_cluster"
  mock_outputs = {
    node_groups = { "node-group" = { security_group_id = "" } }
  }
}

terraform {
  source = "${get_repo_root()}/../modules//elasticache"
}

inputs = {
  name                 = "${include.gitlab_config.locals.prefix}-cache-${local.suffix}"
  description          = "Cache for GitLab ${local.suffix} server."
  logs_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  vpc_id               = dependency.vpc.outputs.vpc_id
  subnet_ids           = [for k, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  security_group_rules = {
    eks_gitlab_cache_traffic = {
      protocol = "tcp"
      type     = "ingress"
      ports    = [6379]
      target   = values(dependency.cluster.outputs.node_groups)[0].security_group_id
    }
  }
}
