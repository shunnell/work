resource "kubernetes_manifest" "rds_secret" {
  depends_on = [kubernetes_manifest.secret_store]
  manifest = yamldecode(<<-YAML
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: ${local.rds_ext_secret}
      namespace: ${kubernetes_namespace.nexus_namespace.metadata[0].name}
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: ${local.secretstore_name}
        kind: SecretStore
      target:
        name: ${local.rds_ext_secret}
      data:
        - secretKey: username
          remoteRef:
            key: ${var.rds_aws_secret}
            property: username
        - secretKey: password
          remoteRef:
            key: ${var.rds_aws_secret}
            property: password
  YAML
  )
}

resource "kubernetes_manifest" "license_secret" {
  depends_on = [kubernetes_manifest.secret_store]
  manifest = yamldecode(<<-YAML
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: ${local.license_ext_secret}
      namespace: ${kubernetes_namespace.nexus_namespace.metadata[0].name}
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: ${local.secretstore_name}
        kind: SecretStore
      target:
        name: ${local.license_ext_secret}
      data:
        - secretKey: ${local.license_ext_secret}
          remoteRef:
            key: ${var.license_secret_arn}
            property: ${var.license_secret_key}
            decodingStrategy: Base64
  YAML
  )
}