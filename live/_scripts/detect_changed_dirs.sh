#!/bin/bash
set -x
# set -e
# Detect Terragrunt live folders that changed
CHANGED_FILES=$(git diff --name-only --ignore-cr-at-eol --ignore-space-at-eol --ignore-space-change --ignore-all-space --ignore-blank-lines --no-color origin/main...HEAD)

# Loop through changed files and extract directories that don't include terragrunt.hcl
for file in $CHANGED_FILES
do
  # Get the directory containing the file
  dir=$(dirname "$file")
  test -f "$dir/terragrunt.hcl" && echo "$dir"
done | sort -ur
