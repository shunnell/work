# Cloud City Live Infrastructure

This repository contains the "live" (as in: currently deployed) infrastructure configuration and tools for infrastructure management for all AWS accounts in the Cloud City project.

# Documentation Index

- [First-time environment setup](_doc/setup.md)
- [How Terragrunt and IaC are used in this repo](_doc/iac_organization.md)
- [Making changes with Terragrunt](_doc/iac_usage.md)

## Quick Start

1. [Set up your environment](_doc/setup.md).
2. Navigate to the `OPR` account's `monitoring` configuration: `cd opr/platform/monitoring`
3. Initialize Terragrunt: `bespinctl iac terragrunt run-all init`
4. Review changes: `bespinctl iac terragrunt run-all plan`
5. Apply changes (only after MR review by other engineers): `bespinctl iac terragrunt apply`

# Repository Organization

There are several classes of files/folders at the top of this repository, which fit into the following rough categories:

- Top-level [terragrunt Cloud City per-account folders](_doc/iac_organization.md).
- Aspirational "someday" folders that will eventually be promoted to top-level Terragrunt per-account folders once the accounts they will represent are created.
- Multi-use terraform/terragrunt "library"-type files used by multiple accounts' IaC systems.
- Support and configuration assets used by developers and the CI/CD pipeline for performing common tasks (e.g. `.gitlab-ci.yml` or the files that comprise `bespinctl`).

The roles/use-cases for important top-level resources are below:

| Folder name      | Used For          | Purpose                                                                                                                                                    | AWS Account ID | Language(s)          |
|------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------------|
| `infra`          | Platform IaC      | IaC code for `Platform-Infra`, the account containing the Platform GitLab instance                                                                         | 381492150796   | Terragrunt/Terraform |
| `data`           | Tenant IaC        | IaC code for the CCD or "Data-Platform" tenant account                                                                                                     | 976193220746   | Terragrunt/Terraform |
| `dev`            | Aspirational      | (TODO) IaC for a shared multi-tenant account for development                                                                                               | N/A            | Terragrunt/Terraform |
| `_envcommon`     | IaC Support Code  | Common Terragrunt files that can be "included" as libraries from other terragrunt folders                                                                  | N/A            | Terragrunt/Terraform |
| `_tests`         | Developer Support | Procedural tests used to validate infrastructure configuration                                                                                             | N/A            | Python               |
| `doc`            | Developer Support | Documentation                                                                                                                                              | N/A            | Markdown             |
| `iva`            | Tenant IaC        | IaC code for the `IVA` (or "Visas") tenant account                                                                                                         | 730335386746   | Terragrunt/Terraform |
| `logs`           | Platform IaC      | IaC code for `Log Archive`, the account that centrally manages the platform's logs                                                                         | 381492049355   | Terragrunt/Terraform |
| `management`     | Platform IaC      | IaC code for the AWS Organizations "master" account, named `FPT847 Dept of State Consular Affairs`                                                         | 590183957203   | Terragrunt/Terraform |
| `network`        | Platform IaC      | IaC code for `Platform-Network`, the account that manages network access for Cloud City                                                                    | 975050075035   | Terragrunt/Terraform |
| `opr`            | Tenant IaC        | IaC code for the "sandbox" (pre-prod/dev/test/staging) account used by the Online Passport Renewal `OPR3` tenant                                           | 730335639457   | Terragrunt/Terraform |
| `pqs`            | Tenant IaC        | IaC code for the `PQS` tenant account                                                                                                                      | 034362069573   | Terragrunt/Terraform |
| `prod`           | Tenant IaC        | IaC code for the `Production`  tenant account (currently used only for `OPR3` production; eventually to be used for other tenants' production deployments) | 390402578610   | Terragrunt/Terraform |
| `src`            | Developer Support | Support code for `bespinctl` and other Python utilities used in this repo                                                                                  | N/A            | Python               |
| `staging`        | Aspirational      | (TODO) IaC for a shared multi-tenant account for staging                                                                                                   | N/A            | Terragrunt/Terraform |
| `subordinateca`  | Platform IaC      | IaC code for the `SubordinateCA` AWS account for platform certificate management                                                                           | 430118816674   | Terragrunt/Terraform |
| `staging`        | Aspirational      | (TODO) IaC for a shared multi-tenant account for testing                                                                                                   | N/A            | Terragrunt/Terraform |

## Support

Contact the platform team

## Contributing

1. Create feature branch
1. Make changes
1. Test locally
1. Create merge request
1. Wait for CI/CD pipeline
1. Get approval
