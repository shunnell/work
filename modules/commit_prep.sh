#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir ${SCRIPT_DIR}/.terraform
export TF_PLUGIN_CACHE_DIR="${SCRIPT_DIR}/.terraform"

find . -type d -name ".terraform" -prune -exec rm -rf {} \;
find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;

for path in $(find . -wholename './*.tf' -printf '%h\n' | sort -u)
do
  echo $path
  cd $path
  job=$(echo $path | cut -c 3- | sed "s;/;-;g")
  echo $job
  terraform init
  terraform validate
  terraform test
  terraform fmt -recursive
  terraform-docs markdown table . --lockfile=false --output-file README.md
  cd $SCRIPT_DIR
  ./validate_module.sh $path
done

find . -type d -name ".terraform" -prune -exec rm -rf {} \;
find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
