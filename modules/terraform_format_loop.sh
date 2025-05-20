#!/bin/bash

# https://olivergondza.github.io/2019/10/01/bash-strict-mode.html
set -euo pipefail

for path in $(find . -wholename './*.tf' -printf '%h\n' | sort -u)
do
  echo "Validating module formatting: $path"
  ./terraform_format.sh $path
  echo "."
  echo "."
  echo "."
  echo "."
  echo "."
done
