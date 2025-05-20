#!/bin/bash

# https://olivergondza.github.io/2019/10/01/bash-strict-mode.html
set -euo pipefail

cd "${1:?Directory is required as first argument}"

for path in $(find . -wholename './*.tf' -printf '%h\n' | sort -u)
do
  echo "Testing module $path"
  ../terraform_test.sh $path
  echo "."
  echo "."
  echo "."
  echo "."
  echo "."
done
