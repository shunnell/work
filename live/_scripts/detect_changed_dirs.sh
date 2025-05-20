#!/bin/bash
set +x
# Detect Terragrunt live folders that changed
CHANGED_FILES=$(git diff --name-only --ignore-cr-at-eol --ignore-space-at-eol --ignore-space-change --ignore-all-space --ignore-blank-lines --no-color origin/main...HEAD)

# Loop through changed files and extract directories that don't include terragrunt.hcl
for file in $CHANGED_FILES
do
  if [[ "$file" == *terragrunt.hcl ]]; then
    # Get the directory containing the file
    dir=$(dirname "$file")
    echo "$dir"
  fi
done | sort -ur
