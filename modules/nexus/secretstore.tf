data "aws_region" "current" {}

# Get the current Account ID
data "aws_caller_identity" "current" {}

resource "kubernetes_manifest" "secret_store" {
  depends_on = [kubernetes_namespace.nexus_namespace, module.nexus_service_account]
  manifest = yamldecode(<<-YAML
    apiVersion: external-secrets.io/v1
    kind: SecretStore
    metadata:
      name: ${local.secretstore_name}
      namespace: ${local.namespace}
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ${data.aws_region.current.region}
          auth:
            jwt:
              serviceAccountRef:
                name: ${module.nexus_service_account.service_account_name}
  YAML
  )
}
