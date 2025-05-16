# Cloud City Infrastructure Modules

This repository contains reusable Terraform modules for Cloud City infrastructure. These modules follow AWS best practices and are designed to be used across different environments.

## Available Modules

### S3 Module
Creates S3 buckets with security best practices enabled.

Key features:
- Server-side encryption (AES-256)
- Versioning support
- Public access blocking
- Configurable tags

### IAM Policy Module
Creates an IAM policy from raw JSON.

### IAM Role Module
Creates an IAM role from raw JSON and attaches a policy to it via the IAM ARN.

### IAM User Module
Creates an IAM user and attaches a policy to it via the IAM ARN.

## Module Development

### Guidelines

1. Each module should:
   - Have a clear single responsibility
   - Include proper documentation
   - Follow security best practices
   - Support tagging
   - Use consistent naming

1. Required files:
   - `main.tf` - Main module logic
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `README.md` - Module documentation

### Testing

Test modules locally:
```bash
cd test/module_name
terraform init
terraform plan
```

## Contributing

1. Create a new branch
1. Make changes
1. Update documentation in module: `terraform-docs markdown table . --lockfile=false --output-file README.md`
1. Run `terraform fmt`
1. Create merge request

## Module Documentation

Each module includes:
- Input variables
- Output values
- Example usage
- Requirements
- Provider requirements

## Support

Contact the platform team

## Other

1. Clear terraform cache:
   ```bash
   find . -type d -name ".terraform" -prune -exec rm -rf {} \;
   find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
   ```
