resource "kubernetes_manifest" "rds_secret" {
  depends_on = [kubernetes_manifest.secret_store]
  manifest = yamldecode(<<-YAML
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: ${local.rds_ext_secret}
      namespace: "${kubernetes_namespace.gitlab_namespace.metadata[0].name}"
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-irsa-store
        kind: SecretStore
      target:
        name: ${local.rds_ext_secret}
      data:
        - secretKey: password
          remoteRef:
            key: ${var.rds_aws_secret}
            property: password
  YAML
  )
}

