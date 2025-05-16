generate "helm_and_kubernetes_providers_tf" {
  path      = "helm_and_kubernetes_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("helm_and_kubernetes_providers.tf")
}
