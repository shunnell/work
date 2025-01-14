#!/bin/bash

set -e

for path in $(find . -wholename './*.tf' -printf '%h\n' | sort -u)
do
  echo $path
  job=$(echo $path | cut -c 3- | sed "s;/;-;g")
  echo $job
  cat <<EOF >> module-validations.yml
$job:
  image: $1
  rules:
    - when: on_success
  script:
    - echo "Validating module $path"
    - chmod a+rx validate_module.sh
    - ./validate_module.sh $path
EOF
done
