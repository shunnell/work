#!/bin/sh
set -eu

cd "${1:?Directory is required as first argument}"

echo "."
echo "---"
echo "."
echo "Terraform initialization..."
terraform init

echo "."
echo "---"
echo "."
echo "Terraform validation..."
terraform validate

echo "."
echo "---"
echo "."
echo "Terraform testing..."
terraform test

echo "."
echo "---"
echo "."
echo "clean up..."
rm -rf .terraform*
