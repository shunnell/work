# Why are we managing this here?
# To enable the Kubernetes Gateway API support within Cert-Manager.
# And to hand-off the ordering rodeo to ArgoCD

module "cert_manager" {
  source = "../../argocd/application"

  argocd_namespace        = var.argocd_namespace
  aws_ecr_service_account = var.aws_ecr_service_account

  app_namespace          = local.cert_manager_namespace
  create_namespace       = true
  app_helm_chart         = "cert-manager"
  app_helm_chart_repo    = "${local.internal_helm_path_root}/jetstack"
  app_helm_chart_version = var.cert_manager_helm_chart_version
  self_heal              = true
  app_helm_values        = <<-YAML
    crds:
      enabled: true
    image:
      repository: ${local.cert_manager_registry}/cert-manager-controller
    config:
      apiVersion: controller.config.cert-manager.io/v1alpha1
      kind: ControllerConfiguration
      logging:
        format: json
      %{if local.deploy_lb}
      enableGatewayAPI: true
      %{endif}
    resources:
      requests:
        cpu: 10m
        memory: 32Mi
      limits:
        memory: 64Mi
    webhook:
      config:
        apiVersion: webhook.config.cert-manager.io/v1alpha1
        kind: WebhookConfiguration
        logging:
          format: json
      resources:
        requests:
          cpu: 10m
          memory: 32Mi
        limits:
          memory: 64Mi
      image:
        repository: ${local.cert_manager_registry}/cert-manager-webhook
    cainjector:
      config:
        apiVersion: cainjector.config.cert-manager.io/v1alpha1
        kind: CAInjectorConfiguration
        logging:
          format: json
      resources:
        requests:
          cpu: 10m
          memory: 32Mi
        limits:
          memory: 64Mi
      image:
        repository: ${local.cert_manager_registry}/cert-manager-cainjector
    acmesolver:
      image:
        repository: ${local.cert_manager_registry}/cert-manager-acmesolver
    startupapicheck:
      resources:
        requests:
          cpu: 10m
          memory: 32Mi
        limits:
          memory: 64Mi
      image:
        repository: ${local.cert_manager_registry}/cert-manager-startupapicheck
    YAML
}

module "awspca_policy" {
  source = "../../iam/policy"

  policy_name        = "${var.cluster_name}-pca-root-ca-policy"
  policy_description = "Allow AWS PCA Issuer access to root CA for Cert-Manager"
  policy_json        = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "awspcaissuer",
          "Action": [
            "acm-pca:DescribeCertificateAuthority",
            "acm-pca:GetCertificate",
            "acm-pca:IssueCertificate"
          ],
          "Effect": "Allow",
          "Resource": "${var.root_ca_arn}"
        }
      ]
    }
    JSON
}

module "awspca_irsa_role" {
  source = "../service_account"

  name                   = "${var.cluster_name}-awspca-issuer"
  cluster_name           = var.cluster_name
  namespace              = local.cert_manager_namespace
  create_service_account = false

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "awspca_attachement" {
  role       = "${var.cluster_name}-awspca-issuer"
  policy_arn = module.awspca_policy.policy_arn

  depends_on = [module.awspca_irsa_role, module.awspca_policy]
}

module "awspca_issuer" {
  source = "../../argocd/application"

  argocd_namespace        = var.argocd_namespace
  aws_ecr_service_account = var.aws_ecr_service_account

  app_namespace          = local.cert_manager_namespace
  app_helm_chart         = "aws-privateca-issuer"
  app_helm_chart_repo    = "${local.internal_helm_path_root}/awspca"
  app_helm_chart_version = var.aws_pca_helm_chart_version
  self_heal              = true
  app_sync_wave          = 1 # sync after cert-manager

  app_helm_values = <<-YAML
    replicaCount: 1
    image:
      repository: ${local.image_path_root}/ecr-public/k1n1h4h4/cert-manager-aws-privateca-issuer
    serviceAccount:
      create: true
      name: ${"${var.cluster_name}-awspca-issuer"}
      annotations:
        eks.amazonaws.com/role-arn: ${module.awspca_irsa_role.iam_role_arn}
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        memory: 64Mi
    YAML
}


# AWS Cluster Issuer
# This is only applied if 'deploy_lb' is 'true' - `traefik.tf`
#
# apiVersion: awspca.cert-manager.io/v1beta1
# kind: AWSPCAClusterIssuer
# metadata:
#   name: ${local.cluster_issuer}
# spec:
#   arn: ${var.root_ca_arn}
#   region: ${local.region}
