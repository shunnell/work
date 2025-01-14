#!/bin/bash

set -e

cd $1
echo "Checking Terraform formatting..."
terraform fmt -check -diff -recursive
# echo "Terraform initialization"
# terraform init -input=false -backend=false
# echo "Terraform validating..."
# terraform validate
# echo "Testing Terraform..."
# terraform test

echo "Checking docs..."
terraform-docs markdown table . --output-mode replace
terraform-docs markdown table . --output-mode replace --output-file README.md --output-check
