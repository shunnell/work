include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vpn" {
  path   = "../../vpn/vpn_vars.hcl"
  expose = true
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/eks"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

dependency "cloud_city_roles" {
  config_path = "../../cloud_city_roles"
  mock_outputs = {
    most_privileged_users = []
  }
}

dependency "vpc" {
  config_path = "../../network/gitlab_vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

locals {
  gitlab_mothership_sg = "sg-0ddc70b704fa064fa"
  vpn_access_rule = {
    type   = "ingress"
    ports  = [443]
    target = include.vpn.locals.vpn_cidr_block
  }
}

terraform {
  source = "${get_repo_root()}/../modules//eks/cluster"
}

inputs = {
  cluster_name = "gitlab"
  vpc_id       = dependency.vpc.outputs.vpc_id
  # TODO remove the excluded AZ in the subnet list when the cluster is recreated:
  subnet_ids              = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  administrator_role_arns = dependency.cloud_city_roles.outputs.most_privileged_users

  node_groups = {
    "gitlab-runners" = {
      size          = 6
      instance_type = "t3.2xlarge"
      # Allow runners to use the pull-through cache (in addition to the built-in default "Read Only" ECR access).
      additional_iam_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly", # TODO should this be ReadOnly so the runner substrate can't pull through?
        "arn:aws:iam::aws:policy/AWSCodeArtifactReadOnlyAccess"
      ]
      security_group_rules = {
        vpn_access = local.vpn_access_rule
        # https://forum.gitlab.com/t/how-does-communicate-gitlab-runners/7553
        # Runners always reach directly to GitLab mothership, communication is all one-way:
        gitlab_runners_to_mothership = {
          type   = "egress"
          ports  = [443]
          target = local.gitlab_mothership_sg
        }
      }
    }
  }

  cloudwatch_log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn

  cluster_security_group_rules = {
    # Per Google, the control plane proper doesn't need to reach VPC endpoints. Hope Google's right!
    vpn_access = local.vpn_access_rule
  }
}
