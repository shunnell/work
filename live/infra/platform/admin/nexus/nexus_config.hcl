
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals

  ## This is the suffix for the environment set to "" for production
  env_suffix     = "test"
  suffix         = local.env_suffix != "" ? "-${local.env_suffix}" : ""
  ecr_host       = "${local.account_vars.account_id}.dkr.ecr.${local.account_vars.region}.amazonaws.com"
  ecr_docker_hub = "${local.ecr_host}/platform/docker"
  ## License needs to be loaded manually in AWS Secrets Manager
  license_secret_arn = "arn:aws:secretsmanager:us-east-1:381492150796:secret:nexus-repo-license.lic-STWnLo"
}

inputs = {
  namespace                  = "nexusrepo${local.suffix}"
  nexus_acm_certificate_arn  = "arn:aws:acm:us-east-1:381492150796:certificate/87b7e093-11ee-4714-b2a0-59d3e29385d5"
  docker_acm_certificate_arn = "arn:aws:acm:us-east-1:381492150796:certificate/678faa86-f0a5-47dd-8b90-4b5c28cd56ae"
  license_secret_key         = "sonatype_license_2024-09-20T172110Z_base64"
  ecr_docker_hub             = local.ecr_docker_hub
  ecr_host                   = local.ecr_host
  release_name               = "nxrm-ha"
  repository                 = "${local.ecr_host}/helm/sonatype"
  chart_version              = "82.0.0"
  replica_count              = 1
  nexus_domain_name          = "nexus.cloud-city"

  tags = {
    purpose = "Nexus"
  }

}