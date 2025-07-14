data "aws_region" "current" {}

locals {
  aws_ecr_regex       = "\\d+[.]dkr[.]ecr[.][a-z-]+\\d[.]amazonaws[.]com"
  app_name            = try(length(var.app_name), 0) == 0 ? var.app_helm_chart : var.app_name
  ecr_oci_secret_name = "ecr-oci-${local.app_name}"
}

resource "kubernetes_manifest" "ecr_authorization_token" {
  count = var.aws_ecr_service_account != null ? 1 : 0
  # https://external-secrets.io/latest/api/generator/ecr/
  manifest = {
    apiVersion = "generators.external-secrets.io/v1alpha1"
    kind       = "ECRAuthorizationToken"
    metadata = {
      name      = "ecr-${local.app_name}"
      namespace = var.argocd_namespace
    }
    spec = {
      region = data.aws_region.current.region
      auth = {
        jwt = {
          serviceAccountRef = {
            name = var.aws_ecr_service_account
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "ecr_oci_secret" {
  count = var.aws_ecr_service_account != null ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = local.ecr_oci_secret_name
      namespace = var.argocd_namespace
    }
    spec = {
      refreshInterval = "1h"
      target = {
        name = local.ecr_oci_secret_name
        template = {
          metadata = {
            labels = {
              "argocd.argoproj.io/secret-type" = "repository"
            }
          }
          data = {
            name      = local.ecr_oci_secret_name
            type      = "helm"
            enableOCI = "true"
            url       = var.app_helm_chart_repo
            password  = "{{ .password }}"
            username  = "{{ .username }}"
          }
        }
      }
      dataFrom = [
        {
          sourceRef = {
            generatorRef = {
              apiVersion = kubernetes_manifest.ecr_authorization_token[0].object.apiVersion
              kind       = kubernetes_manifest.ecr_authorization_token[0].object.kind
              name       = kubernetes_manifest.ecr_authorization_token[0].object.metadata.name
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "argocd_helm_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = local.app_name
      namespace = var.argocd_namespace
    }
    spec = {
      project = var.argocd_app_project
      source = {
        chart          = var.app_helm_chart
        repoURL        = var.app_helm_chart_repo
        targetRevision = var.app_helm_chart_version
        helm = {
          releaseName = local.app_name
          values      = var.app_helm_values
        }
      }
      destination = {
        server    = var.app_destination
        namespace = var.app_namespace
      }
      syncPolicy = {
        syncOptions = [
          "ServerSideApply=true"
        ]
        automated = {
          prune    = var.prune
          selfHeal = var.self_heal
        }
      }
    }
  }
}
