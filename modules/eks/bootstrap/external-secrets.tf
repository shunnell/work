module "external_secrets" {
  source        = "../../helm"
  repository    = "${local.external_secrets_repo_root}/charts"
  chart         = "external-secrets"
  namespace     = kubernetes_namespace.namespaces["external-secrets"].metadata[0].name
  release_name  = "external-secrets"
  chart_version = var.external_secrets_helm_chart_version
  # We need to force it to use the VPC-regional STS endpoint, since it hardcodes the public (inaccessible) STS endpoint
  # by default. The other settable endpoints are configured to be regional as well, for good measure, but only STS was
  # observed to cause issues if not set.
  # Ref (search "Custom Endpoints"): https://external-secrets.io/v0.5.0/provider-aws-secrets-manager/
  # Ref: https://github.com/external-secrets/external-secrets/issues/651#issuecomment-1024234516
  values = [<<-YAML
    installCRDs: true
    image:
      repository: "${local.external_secrets_repo_root}/external-secrets"
    webhook:
      image:
        repository: "${local.external_secrets_repo_root}/external-secrets"
    certController:
      image:
        repository: "${local.external_secrets_repo_root}/external-secrets"
    extraEnv:
      - name: AWS_STS_ENDPOINT
        value: "https://sts.${local.region}.amazonaws.com"
      - name: AWS_SECRETSMANAGER_ENDPOINT
        value: "https://secretsmanager.${local.region}.amazonaws.com"
      - name: AWS_SSM_ENDPOINT
        value: "https://ssm.${local.region}.amazonaws.com"
    YAML
  ]
}
