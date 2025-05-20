#!/bin/bash
set +x
# perform terragrunt action of list of changed directories from file
while read dir
do
  echo "directory: $dir"
  if [ -d $dir ]
  then
    # export TERRA_UNIT_DIR=$dir
    # export TG_OUT_DIR=$CI_PROJECT_DIR/.tfplan/$TERRA_UNIT_DIR
    # export TG_JSON_OUT_DIR=$CI_PROJECT_DIR/.tfplan_json/$TERRA_UNIT_DIR
    # echo $TG_OUT_DIR
    # echo $TG_JSON_OUT_DIR
    cd $dir
    terragrunt $ACTION
    if [[ $ACTION == *"plan"* ]]; then
      terragrunt show -json tfplan.tfplan > tfplan.json
      # mkdir -p $TG_OUT_DIR
      # mkdir -p $TG_JSON_OUT_DIR
      # cp ./**/tfplan.tfplan $TG_OUT_DIR/
      # cp tfplan.json $TG_JSON_OUT_DIR/
    fi
  fi
  cd $CI_PROJECT_DIR
done < $CHANGED_DIRS
