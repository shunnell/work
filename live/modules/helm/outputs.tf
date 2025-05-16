output "namespace" {
  description = "Namespace into which this Helm release was deployed. Included for convenience: depending on this output will wait until the release is present."
  depends_on  = [helm_release.this]
  value       = helm_release.this.metadata[0].namespace
}

output "manifest" {
  description = "The full YAML manifest generated for this Helm release"
  depends_on  = [helm_release.this]
  value       = helm_release.this.manifest
}

output "metadata" {
  description = "Helm release metadata"
  depends_on  = [helm_release.this]
  value       = helm_release.this.metadata[0]
}

output "status" {
  description = "Helm release status"
  depends_on  = [helm_release.this]
  value       = helm_release.this.status
}
