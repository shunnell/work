output "domain_arn" {
  description = "The ARN of the CodeArtifact domain"
  value       = try(aws_codeartifact_domain.this[0].arn, null)
}

output "domain_name" {
  description = "The name of the CodeArtifact domain"
  value       = try(aws_codeartifact_domain.this[0].domain, null)
}

output "domain_owner" {
  description = "The AWS account ID that owns the domain"
  value       = try(aws_codeartifact_domain.this[0].owner, null)
}

output "domain_url" {
  description = "The URL of the CodeArtifact domain"
  value       = try(aws_codeartifact_domain.this[0].asset_size_bytes, null)
}

output "repositories" {
  description = "Map of created repositories"
  value = {
    for name, repo in aws_codeartifact_repository.this : name => {
      arn         = repo.arn
      name        = repo.repository
      domain_name = repo.domain
      url         = try(repo.external_connections_url, null)
    }
  }
}
