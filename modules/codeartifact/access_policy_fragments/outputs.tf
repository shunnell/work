output "basic_access" {
  description = "A fragment of an IAM Policy Statement that provides 'basic' acess to CodeArtifact. This statement is needed for logging into code aritfact via tools like pip and npm."
  value = {
    Sid    = "CodeArtifactBasicAccess"
    Effect = "Allow"
    Action = [
      "codeartifact:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
      # All tenants can see (describe, list) everything in CodeArtifact, but pull/push of data from specific repos is
      # restricted by other stanzas in the managed policies:
      "codeartifact:Describe*",
      "codeartifact:List*",
    ]
  }
}

output "push" {
  description = "A fragment of an IAM Policy Statement that provides 'push' acess to CodeArtifact, includes all actions for 'pull'. Push access means allowing the publishing of new artifacts to a repository."
  value = {
    Sid    = "CodeArtifactPush"
    Effect = "Allow"
    Action = setunion(local.actions.codeartifact.pull, local.actions.codeartifact.push)
  }
}

output "pull" {
  description = "A fragment of an IAM Policy Statement that provides 'pull' acess to CodeArtifact, includes all actions for 'pull'. Pull access means allowing the retrieval of artifacts from a repository."
  value = {
    Sid    = "CodeArtifactPull"
    Effect = "Allow"
    Action = local.actions.codeartifact.pull
  }
}

