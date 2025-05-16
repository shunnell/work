This module provides re-usable fragments of IAM policy for allowing access to CodeArtifact repositories.

This module doesn't fully implement either an Identity Policy or a Resource policy, but can be re-used to build up those.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_basic_access"></a> [basic\_access](#output\_basic\_access) | A fragment of an IAM Policy Statement that provides 'basic' acess to CodeArtifact. This statement is needed for logging into code aritfact via tools like pip and npm. |
| <a name="output_pull"></a> [pull](#output\_pull) | A fragment of an IAM Policy Statement that provides 'pull' acess to CodeArtifact, includes all actions for 'pull'. Pull access means allowing the retrieval of artifacts from a repository. |
| <a name="output_push"></a> [push](#output\_push) | A fragment of an IAM Policy Statement that provides 'push' acess to CodeArtifact, includes all actions for 'pull'. Push access means allowing the publishing of new artifacts to a repository. |
<!-- END_TF_DOCS -->