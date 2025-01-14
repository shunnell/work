# Cloud City Live Infrastructure

This repository contains the live infrastructure configurations for Cloud City environments. It uses Terragrunt to manage multiple environments and services in a DRY way.

## Environment Structure
  
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

## Account Configuration

Each account directory contains a `account.hcl` file that defines:
- Account-specific resource configurations
- Environment variables

[infra/platform/gitops/iam/terragrunt/policy/iam_policy_terragrunter.json](infra/platform/gitops/iam/terragrunt/policy/iam_policy_terragrunter.json) will contain the accounts that are allowed to be maintained by this pipeline.

In the case that an account(s) is (re)created, follow the steps in [### Local or New Account
](#local-or-new-account) to restore/add the account(s).

### Component Configuration

Each component directory contains its own `terragrunt.hcl` file that defines:
- Component-specific resources
- Dependencies between components
- Component-specific variables
- Resource configurations

## Prerequisites

- Terragrunt
- Terraform 
- Access to Cloud City AWS account
- An AWS profile configured with the `role_arn` set to the "terragrunter" role ARN in the `infra` account.  Set this as your default profile.

## Quick Start

1. Navigate to desired environment and service:
    ```bash
    cd dev/s3
    ```

1. Initialize Terragrunt:
    ```bash
    terragrunt init
    ```

1. Review changes:
    ```bash
    terragrunt plan
    ```

1. Apply changes:
    ```bash
    terragrunt apply
    ```

## Environment Configuration

### Development (dev)

Current services:

- **S3**: Storage buckets
  - Versioning enabled
  - Encryption enabled
  - Public access blocked

### Remote State

- Backend: AWS S3
- Bucket: `dos-cloudcity-infra-terraform-state`
- DynamoDB Table: `dos-cloudcity-infra-terraform-locks`
- State Path: `<environment>/<service>/terraform.tfstate`

## Common Commands

Validate HCL:
```bash
terragrunt hclvalidate
```

Format HCL:
```bash
terragrunt hclfmt
```

Apply changes to all services in an environment:
```bash
cd dev
terragrunt run-all apply
```

Destroy a specific service:
```bash
cd dev/s3
terragrunt destroy
```

Format all Terragrunt files:
```bash
terragrunt hclfmt
```

## Best Practices

1. Always work in the correct environment directory
1. Review plans before applying
1. Use consistent naming:
   - Resources: `<environment>-<service>-<resource>`
   - Tags: Follow organization standards

## Troubleshooting

Common issues:

1. State Lock Issues
    ```bash
    terragrunt force-unlock <LOCK_ID>
    ```

1. Initialization Failures
    ```bash
    terragrunt init --reconfigure
    ```

### Local or New Account

Account roles and policies need to be created for cross-account management through a pipeline.  Create these resources from a "local" system for new or recreated accounts, then allow a pipeline to manage them after.

1. Comment `assume_role` blocks in [root.hcl](root.hcl) and uncomment `profile`.
1. Get `infra` account ID and `AWSReservedSSO_AWSAdministratorAccess_*` role arn, then update:
    1. [infra/platform/gitops/iam/terragrunt/role/iam_role_terragrunter.json](infra/platform/gitops/iam/terragrunt/role/iam_role_terragrunter.json)
    1. [_envcommon/platform/gitops/iam/terragrunter/iam_role_assume_terragrunter.json](_envcommon/platform/gitops/iam/terragrunter/iam_role_assume_terragrunter.json)
1. Get account IDs for all accounts and update [infra/platform/gitops/iam/terragrunt/policy/iam_policy_terragrunter.json](infra/platform/gitops/iam/terragrunt/policy/iam_policy_terragrunter.json).
1. Update `[account]` ID in all `[account]/account.hcl`.
1. Starting with `infra`, and ending with `infra`, open `bash` in all accounts `[account]/platform/gitops/iam/terragrunter` and perform `Terragrunt` operations:
    ```bash
    export AWS_PROFILE=[account]
    terragrunt run-all init
    terragrunt run-all plan -out=[account].plan
    terragrunt run-all apply "[account].plan"
    terragrunt run-all plan -out=[account].plan
    terragrunt run-all apply "[account].plan"
    ```
1. !! Uncomment/revert the `assume_role` blocks in [root.hcl](root.hcl) and `profile` !!
1. Configure an AWS profile with the `role_arn` set to the "terragrunter" role ARN in the `infra` account.  Set this as your default profile.
1. TODO :: setup GitLab steps
1. TODO :: recreate and push repos to GitLab steps

## Support

Contact the platform team

## Contributing

1. Create feature branch
1. Make changes
1. Test locally
1. Create merge request
1. Wait for CI/CD pipeline
1. Get approval
