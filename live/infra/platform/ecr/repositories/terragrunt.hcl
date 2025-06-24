include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team_repositories" {
  path = "${get_repo_root()}/_envcommon/platform/ecr/team_repositories.hcl"
}

dependency "account_list" {
  config_path = "${get_repo_root()}/management/platform/sso/utilities/account_list"
  mock_outputs = {
    accounts = { "1234" = "tenantname" }
  }
}

dependency "registry" {
  config_path = "../registry"
  mock_outputs = {
    pull_through_configurations = {}
  }
}

locals {
  # TODO: These were created via the prior pull-through caching that shared (and thus could not attribute for security
  #   purposes) pulled-through images across all tenants. Dependencies on these images should be removed and the list
  #   should eventually be reduced down to empty as we migrate folks to use their own pulled-through images:
  to_be_removed_shared_repos_from_legacy_pull_through = [
    "ecr-public/docker/library/alpine",
    "docker-hub/stoplight/spectral",
    "gitlab/security-products/secrets",
    "quay/terraform-docs/terraform-docs",
    "docker-hub/hashicorp/terraform",
    "docker-hub/hadolint/hadolint",
    "gitlab/security-products/kics",
    "docker-hub/devopsinfra/docker-terragrunt",
    "k8s/external-dns/external-dns",
    "ecr-public/eks-distro/kubernetes/pause",
    "ecr-public/docker/library/node",
    "gitlab/security-products/gemnasium",
    "docker-hub/amazon/aws-cli",
    "docker-hub/outofcoffee/imposter-distroless",
    "ecr-public/docker/library/postgres",
    "ecr-public/docker/library/redis",
    "github/external-secrets/charts/external-secrets",
    "docker-hub/library/redis",
    "docker-hub/library/hello-world",
    "gitlab/security-products/gemnasium-python",
    "gitlab/security-products/semgrep",
    "docker-hub/library/alpine",
    "gitlab/security-products/gitlab-advanced-sast",
    "gitlab/security-products/gemnasium-maven",
    "ecr-public/karpenter/controller",
    "gitlab/security-products/dast",
  ]
}

inputs = {
  aws_accounts_with_pull_access = keys(dependency.account_list.outputs.accounts)
  # Enable all upstreams for the platform ECR, even the rarely-used ones (see team_repositories.hcl for details):
  pull_through_configurations = dependency.registry.outputs.pull_through_configurations
  legacy_ecr_repository_names_to_be_migrated = concat(local.to_be_removed_shared_repos_from_legacy_pull_through, [
    "cloud-city/infra/podman",
    "cloud-city/infra/terragrunt",
    "cloud-city/platform/podman",
    "cloud-city/platform/terraform",
    "cloud-city/platform/terragrunt",
    "gcr/distroless/nodejs18-debian12",
    "gcr/distroless/python3-debian12",
    "helm/aws/eks-charts/aws-load-balancer-controller",
    "helm/bitnami/external-dns",
    "helm/gitlab/cert-manager",
    "helm/grafana/alloy",
    "helm/grafana/grafana",
    "helm/grafana/k8s-monitoring",
    "helm/grafana/loki-distributed",
    "helm/grafana/mimir-distributed",
    "helm/grafana/tempo-distributed",
    "helm/jetstack/cert-manager",
    "helm/karpenter/karpenter",
    "helm/kubernetes/external-dns",
    "helm/prometheus-community/kube-prometheus-stack",
    "helm/prometheus-community/kube-state-metrics",
    "helm/prometheus-community/prometheus-node-exporter",
    "helm/prometheus-community/prometheus-operator-crds",
    "helm/sonatype/nxrm-ha",
  ])
}
