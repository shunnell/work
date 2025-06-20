#!/bin/sh
set -eu

IMAGE=${1:?Image is required as first argument}

# For each base directory that contains modules:
#  enter that directory and test each of those modules
for path in $(find . -wholename './*.tf' -exec dirname {} \; | cut -d / -f 2 | sort -u)
do
  echo $path
  cat >> module_tests.yml <<-YAML
    terraform_test-${path}:
      image: ${IMAGE}
      rules:
        - when: on_success
      before_script:
        - cp /etc/gitlab-runner/certs/gitlab.cloud-city.crt /usr/local/share/ca-certificates/
        - update-ca-certificates
      script:
        - echo "Testing module $path"
        - chmod a+rx *.sh
        - ./terraform_test_loop.sh $path
YAML
done
