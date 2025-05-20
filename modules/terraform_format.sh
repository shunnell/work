#!/bin/bash

# https://olivergondza.github.io/2019/10/01/bash-strict-mode.html
set -euo pipefail

cd "${1:?Directory is required as first argument}"

echo "Checking Terraform formatting..."
terraform fmt -check -diff -recursive
