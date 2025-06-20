module "k8s_secret_access_service_account" {
  source                      = "../service_account"
  use_name_as_iam_role_prefix = true
  name                        = "k8s-repo-secret-access"
  cluster_name                = var.cluster_name
  namespace                   = var.argocd_namespace
  secret_arns                 = ["arn:aws:secretsmanager:::secret:${var.k8s_repo_secret_name}*"]
}

resource "kubernetes_manifest" "secret_store" {
  manifest = yamldecode(<<-YAML
    apiVersion: external-secrets.io/v1
    kind: SecretStore
    metadata:
      name: aws-secretsmanager
      namespace: "${var.argocd_namespace}"
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ${data.aws_region.current.region}
          auth:
            jwt:
              serviceAccountRef:
                name: ${module.k8s_secret_access_service_account.service_account_name}
  YAML
  )
}

resource "kubernetes_manifest" "repo_secret" {
  depends_on = [kubernetes_manifest.secret_store]
  manifest = yamldecode(<<-YAML
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: ${module.k8s_secret_access_service_account.service_account_name}
      namespace: "${var.argocd_namespace}"
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secretsmanager
        kind: SecretStore
      target:
        name: ${module.k8s_secret_access_service_account.service_account_name}
        template:
          metadata:
            labels:
              argocd.argoproj.io/secret-type: repository
          data:
            project: default
            insecure: "true"
            name: "cloud-city-platform-gitops-kubernetes"
            type: git
            url: "${local.repo_url}"
            username: "{{ `{{ .user }}` }}"
            password: "{{ `{{ .token }}` }}"
      data:
        - secretKey: user
          remoteRef:
            key: ${var.k8s_repo_secret_name}
            property: ${var.k8s_repo_secret_user_key}
            version: AWSCURRENT
        - secretKey: token
          remoteRef:
            key: ${var.k8s_repo_secret_name}
            property: ${var.k8s_repo_secret_token_key}
            version: AWSCURRENT
  YAML
  )
}
