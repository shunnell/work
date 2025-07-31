terraform {
  source = "${get_repo_root()}/../modules//eks/tenant"
}

dependency "cluster" {
  config_path = "../.."
  mock_outputs = {
    cluster_name = ""
  }
}

dependency "tooling" {
  config_path = "../../tooling"
  mock_outputs = {
    cluster_issuer     = ""
    gateway_class_name = ""
    websecure_port     = 0
    web_port           = 0
  }
}

inputs = {
  cluster_name       = dependency.cluster.outputs.cluster_name
  cluster_issuer     = dependency.tooling.outputs.cluster_issuer
  gateway_class_name = dependency.tooling.outputs.gateway_class_name
  web_port           = dependency.tooling.outputs.web_port
  websecure_port     = dependency.tooling.outputs.websecure_port
}
