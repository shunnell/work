include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//eks/"
}

dependency "cluster_role" {
  config_path = "../cluster-role"
  mock_outputs = {
    role_arn = "arn:aws:iam::111111111111:role/mock_cluster_role"
  }
}

dependency "node_role" {
  config_path = "../node-group-role"
  mock_outputs = {
    role_arn = "arn:aws:iam::111111111111:role/mock-node-group-role"
  }
}

inputs = {
  cluster_name       = "eks-cluster-1"
  cluster_role_arn   = dependency.cluster_role.outputs.role_arn
  security_group_ids = ["sg-087f9ed0b107ba48b"]
  subnet_ids         = ["subnet-03d839cf71edb88ad", "subnet-06fc6c4ed6c35520a", "subnet-0d0765e05822f5f87"]
  vpc_endpoint_sg_id = "sg-07fca7ebebc1d60f2"
  vpc_id             = "vpc-01912bb2c7a00113e"
  node_groups = [{
    name          = "dos-gitlab-central-runner-eks-node-group",
    node_role_arn = dependency.node_role.outputs.role_arn
  }]
}
