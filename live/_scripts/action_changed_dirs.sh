#!/bin/bash
set +x
# perform terragrunt action of list of changed directories from file
while read TERRA_UNIT_DIR
do
  echo "directory: $TERRA_UNIT_DIR"
  if [ -d $TERRA_UNIT_DIR ]
  then
    cd $TERRA_UNIT_DIR
    pwd
    terragrunt $ACTION
    if [[ $ACTION == *"plan"* ]]; then terragrunt show -json tfplan.tfplan > tfplan.json; fi
  fi
  cd $CI_PROJECT_DIR
done < $CHANGED_DIRS
df -ah
