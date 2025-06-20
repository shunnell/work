#!/bin/sh
set -eu

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
