locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  # root_ca_arn = "arn:aws:acm-pca:us-east-1:381492150796:certificate-authority/0f90d56f-1e7c-4c19-b5ad-d88264f07a65" # infra
  root_ca_arn = "arn:aws:acm-pca:us-east-1:430118816674:certificate-authority/ec9f73e8-7280-4952-9e27-52445911aed7" # subordinateca
}

terraform {
  source = "${get_repo_root()}/../modules//eks/bootstrap"
}

dependency "cluster" {
  config_path = "../"
  mock_outputs = {
    cluster_name                         = ""
    shared_node_security_group_id        = ""
    aws_internal_cluster_egress_rule_ids = []
    vpc_id                               = ""
  }
}

inputs = {
  cluster_name                         = dependency.cluster.outputs.cluster_name
  aws_internal_cluster_egress_rule_ids = dependency.cluster.outputs.aws_internal_cluster_egress_rule_ids
  root_ca_arn                          = local.root_ca_arn
}
