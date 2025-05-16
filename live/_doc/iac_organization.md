# Managing Cloud City Infrastructure as Code (IaC) with Terragrunt

Cloud City uses [terragrunt](https://terragrunt.gruntwork.io/) to apply [terraform](https://www.terraform.io/) changes to AWS resources. The eventual goal is for all or almost all AWS resources to be managed with these tools, with a minimum of hand configuration.

Terragrunt/terraform code to manage Cloud City resources is organized by AWS account, in folders.

Running Terragrunt in any subdirectory of one of the below folders will automatically manage infrasructure defined in Terragrunt HCL manifests in that folder to the corresponding account. 

# Top level per-account directories in which Terragrunt can be invoked

| Folder name  | Used For          | Purpose                                                                                                                                                    | AWS Account ID | Language(s)          |
|--------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------------|
| `infra`      | Platform IaC      | IaC code for `Platform-Infra`, the account containing the Platform GitLab instance                                                                         | 381492150796   | Terragrunt/Terraform |
| `data`       | Tenant IaC        | IaC code for the CCD or "Data-Platform" tenant account                                                                                                     | 976193220746   | Terragrunt/Terraform |
| `iva`        | Tenant IaC        | IaC code for the `IVA` (or "Visas") tenant account                                                                                                         | 730335386746   | Terragrunt/Terraform |
| `logs`       | Platform IaC      | IaC code for `Log Archive`, the account that centrally manages the platform's logs                                                                         | 381492049355   | Terragrunt/Terraform |
| `management` | Platform IaC      | IaC code for the AWS Organizations "master" account, named `FPT847 Dept of State Consular Affairs`                                                         | 590183957203   | Terragrunt/Terraform |
| `network`    | Platform IaC      | IaC code for `Platform-Network`, the account that manages network access for Cloud City                                                                    | 975050075035   | Terragrunt/Terraform |
| `opr`        | Tenant IaC        | IaC code for the "sandbox" (pre-prod/dev/test/staging) account used by the Online Passport Renewal `OPR3` tenant                                           | 730335639457   | Terragrunt/Terraform |
| `pqs`        | Tenant IaC        | IaC code for the `PQS` tenant account                                                                                                                      | 034362069573   | Terragrunt/Terraform |
| `prod`       | Tenant IaC        | IaC code for the `Production`  tenant account (currently used only for `OPR3` production; eventually to be used for other tenants' production deployments) | 390402578610   | Terragrunt/Terraform |
| `subordinateca`  | Platform IaC      | IaC code for the `SubordinateCA` AWS account for platform certificate management                                                                      | 430118816674   | Terragrunt/Terraform |

Other top level directories contain supporting or aspirational/to-be-used Terragrunt code; more details about those folders are in [organization](./organization.md).

# Directory Organization, State Files, and You

The directory in which you invoke Terragrunt is very important, and controls three things:

1. What account changes are made in.
2. What infrastructure is changed/managed in that account.
3. What Terraform state file is used.

Running Terragrunt (either directly or via `bespinctl`) always addresses the infrastructure defined in a file called `terragrunt.hcl` in the current working directory. 

Each component directory's `terragrunt.hcl` file defines:
- Component-specific resources
- Dependencies between components
- Component-specific variables
- Resource configurations

Within a top-level per-AWS-account folder, working directories are organized by their purpose; they are used to descriptively name 

For example, running `terragrunt apply` in `opr/platform/monitoring` will cause Terragrunt to apply changes that manage the monitoring subsystems of the platform in the OPR tenant AWS account.

Other than `cd`ing into this directory before running Terragrunt, no other configuration is needed on your part to "point"
Terragrunt at a specific AWS account. This automatic-account-detection system is configured in the top-level `root.hcl` file; change it with care.

The path to a given directory corresponds to where Terraform places its state file (recording what resources are managed after an `apply`) in production. Because of this, **moving Terragrunt files that manage existing infrastructure between different directories is dangerous**. If you need to move Terragrunt files around between directories, either fully destroy the infrastructure and state file corresponding to the original directory and bring the infrastructure up "clean" in the new directory, or else do the needful `terragrunt import` commands in the new directory before `terragrunt state rm`ing resources in the old directory. 

### Terraform State

**Note: *all* Terraform state is stored in the `infra` account, not in tenant accounts (even if the state corresponds to resources in those accounts).**

- Account: `Platform-Infra` (381492150796).
- Backend: AWS S3
- Bucket: `dos-cloudcity-infra-terraform-state`
- DynamoDB Table: `dos-cloudcity-infra-terraform-locks`
- State Path: `<environment>/<hcl_file_path>/terraform.tfstate`

# Account Configuration

Each top-level account directory contains an `account.hcl` file that defines:
- Account-specific resource configurations
- Environment variables

[infra/platform/gitops/iam/terragrunt/policy/iam_policy_terragrunter.json](../infra/platform/gitops/iam/terragrunt/policy/iam_policy_terragrunter.json) will contain the accounts that are allowed to be maintained by this pipeline.


### Component Configuration

Each component directory contains its own `terragrunt.hcl` file that defines:
- Component-specific resources
- Dependencies between components
- Component-specific variables
- Resource configurations


# Desired Eventual Structure

Once multi-tenant accounts are in use, the following structure will be present:

```
live/
├── dev/                       # Development environment
│   └── opr/                   # OPR team resources
│       ├── terragrunt.hcl     # OPR team configuration
│       ├── s3/                # S3 component
│       │   └── terragrunt.hcl # S3-specific configuration
│       └── rds/               # RDS component
│           └── terragrunt.hcl # RDS-specific configuration
│   └── iva/                   # IVA team resources
│       ├── terragrunt.hcl     # IVA team configuration
│       ├── ec2/               # EC2 component
│       │   └── terragrunt.hcl # EC2-specific configuration
│       └── vpc/               # VPC component
│           └── terragrunt.hcl # VPC-specific configuration
├── staging/                   # Staging environment (future)
├── prod/                      # Production environment (future)
└── infra/                     # Infrastructure configurations, resources and bootstrap
```