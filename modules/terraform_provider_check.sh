#!/bin/sh
set -eu

cd "${1:?Directory is required as first argument}"

echo "Checking that no providers are declared..."
# Gross regex, but structural linting would require a new CI image with an HCL parser or terraform customizable linter.
# TODO once either of those are available, use them instead of grep.

if grep -Pr --include \*.tf '^\s*provider\s*\S+\s*[{]'; then
  echo "Module declares a provider. Providers should be set up in 'live' root.hcl in almost every case." 1>&2
  echo "The 'aws' provider should never be declared outside of root.hcl in either repo." 1>&2
  exit 1
else
  echo "No provider declarations detected!" 1>&2
fi
