#/bin/bash

set -eu
set -o pipefail

ACTIVATE_PARAMETERS=$(aws ssm create-activation \
  --default-instance-name "DockerSSM" \
  --iam-role "service-role/AmazonEC2RunCommandRoleForManagedInstances" \
  --registration-limit 1)

ACTIVATE_CODE=$(echo ${ACTIVATE_PARAMETERS} | jq -r .ActivationCode)
ACTIVATE_ID=$(echo ${ACTIVATE_PARAMETERS} | jq -r .ActivationId)
amazon-ssm-agent -register -code "${ACTIVATE_CODE}" -id "${ACTIVATE_ID}" -region "ap-northeast-1" -y
amazon-ssm-agent
