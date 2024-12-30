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

## Team Configuration

Each team directory contains a `terragrunt.hcl` file that defines:
- Team-specific resource configurations
- Environment variables

### Component Configuration

Each component directory contains its own `terragrunt.hcl` file that defines:
- Component-specific resources
- Dependencies between components
- Component-specific variables
- Resource configurations

## Prerequisites

- AWS CLI with `infra` profile configured
- Terragrunt
- Terraform 
- Access to Cloud City AWS account

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

### ! Complete Loss !

Account roles and policies need to be created for cross-account management through a pipeline.  Create these resources from a "local" system first, then allow a pipeline to manage them after.
1. Uncomment the profile definition for the `remote_state` in [root.hcl](root.hcl).
1. Get `infra` account ID and update [_envcommon\platform\gitops\iam\terragrunter\iam_role_assume_terragrunter.json](_envcommon\platform\gitops\iam\terragrunter\iam_role_assume_terragrunter.json).
1. Get account IDs for other accounts and update [infra\platform\gitops\iam\terragrunt\policy\iam_policy_terragrunter.json](infra\platform\gitops\iam\terragrunt\policy\iam_policy_terragrunter.json).
1. Open `bash` in [infra\platform\gitops\iam\terragrunt](infra\platform\gitops\iam\terragrunt) and perform `Terragrunt` operations.
    ```bash
    export AWS_PROFILE=infra
    terragrunt run-all init
    terragrunt run-all plan -out=infra.plan
    terragrunt run-all show infra.plan
    terragrunt run-all apply infra.plan
    ```
1. Open `bash` in other accounts `[account]\platform\gitops\iam\terragrunter` and perform `Terragrunt` operations (similar to above).
    ```bash
    export AWS_PROFILE=[account]
    terragrunt run-all init
    terragrunt run-all plan -out=[account].plan
    terragrunt run-all show [account].plan
    terragrunt run-all apply [account].plan
    ```
1. TODO :: setup GitLab
1. TODO :: recreate and push repos to GitLab
1. **!! Comment the profile definition for the `remote_state` in [root.hcl](root.hcl) !!**

## Support

Contact the platform team

## Contributing

1. Create feature branch
1. Make changes
1. Test locally
1. Create merge request
1. Wait for CI/CD pipeline
1. Get approval
