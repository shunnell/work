#!/bin/bash
set -e
# Detect Terragrunt live folders that changed
CHANGED_FILES=$(git diff --name-only origin/main...HEAD)

# Loop through changed files and extract directories that don't include terragrunt.hcl
for file in $CHANGED_FILES; do
  if [[ "$file" == *.hcl &&  \
        "$file" != *root.hcl &&  \
        "$file" != *account.hcl &&  \
        "$file" != *team.hcl &&  \
        "$file" != *terragrunt.hcl ]]; then
    # Get the directory containing the file
    dir=$(dirname "$file")
    echo "$dir"
  fi
done | sort -u