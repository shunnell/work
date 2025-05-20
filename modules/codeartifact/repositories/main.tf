resource "aws_codeartifact_domain" "this" {
  count = var.create_domain ? 1 : 0

  domain         = var.domain_name
  encryption_key = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = var.domain_name
    }
  )
}

resource "aws_codeartifact_repository" "this" {
  depends_on = [aws_codeartifact_domain.this]
  for_each   = { for repo in var.repositories : repo.name => repo }

  repository  = each.value.name
  domain      = var.domain_name
  description = each.value.description

  dynamic "upstream" {
    for_each = each.value.upstream_repositories != null ? each.value.upstream_repositories : []
    content {
      repository_name = upstream.value
    }
  }

  dynamic "external_connections" {
    for_each = each.value.external_connections != null ? toset(each.value.external_connections) : []
    content {
      external_connection_name = external_connections.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}
