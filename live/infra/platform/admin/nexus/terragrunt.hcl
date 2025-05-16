include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  ecr_host       = "${local.account_vars.account_id}.dkr.ecr.${local.account_vars.region}.amazonaws.com"
  ecr_docker_hub = "${local.ecr_host}/docker-hub"
  name           = "nexusrepo"
}

dependency "cluster" {
  config_path = "../sandbox"
  mock_outputs = {
    cluster_name = "name"
  }
}

dependency "db" {
  config_path = "rds"
  mock_outputs = {
    aurora_serverless_v2_cluster_endpoint      = ""
    aurora_serverless_v2_cluster_port          = 0
    aurora_serverless_v2_cluster_database_name = ""
    aurora_serverless_v2_cluster_credentials   = { username = "", password = "" }
  }
}

dependency "license" {
  config_path = "license"
  mock_outputs = {
    license_base64 = {
      "sonatype-license-2024-09-20T172110Z.lic.base64" = ""
    }
  }
}

terraform {
  source = "${get_repo_root()}/../modules//helm"
}

inputs = {
  cluster_name = dependency.cluster.outputs.cluster_name

  chart            = "nxrm-ha"
  namespace        = local.name
  release_name     = local.name
  repository       = "${local.ecr_host}/helm/sonatype"
  chart_version    = "79.1.0"
  create_namespace = true

  set_sensitive = {
    "secret.db.password"                              = dependency.db.outputs.aurora_serverless_v2_cluster_credentials.password
    "secret.license.licenseSecret.fileContentsBase64" = dependency.license.outputs.license_base64["sonatype-license-2024-09-20T172110Z.lic.base64"]
  }
  values = [<<-YAML
    namespaces:
      nexusNs:
        enabled: false
        name: ${local.name}
    pvc:
      volumeClaimTemplate:
        enabled: true
      storage: 100Gi
    storageClass:
      name: ebs-sc
    statefulset:
      container:
        image:
          repository: ${local.ecr_docker_hub}/sonatype/nexus3
      requestLogContainer:
        image:
          repository: ${local.ecr_docker_hub}/library/busybox
      auditLogContainer:
        image:
          repository: ${local.ecr_docker_hub}/library/busybox
      taskLogContainer:
        image:
          repository: ${local.ecr_docker_hub}/library/busybox
      initContainers:
        - name: chown-nexusdata-owner-to-nexus-and-init-log-dir
          image: ${local.ecr_docker_hub}/library/busybox:1.33.1
    secret:
      dbSecret:
        enabled: true
      db:
        user: ${dependency.db.outputs.aurora_serverless_v2_cluster_credentials.username}
        host: ${dependency.db.outputs.aurora_serverless_v2_cluster_endpoint}
      nexusAdminSecret:
        enabled: true
      license:
        licenseSecret:
          enabled: true
    YAML
  ]

}
