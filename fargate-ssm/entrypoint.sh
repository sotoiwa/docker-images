#/bin/bash

set -eu
set -o pipefail

ACTIVATE_PARAMETERS=$(aws ssm create-activation \
  --default-instance-name "${RESOURCE_STAGE}-${SERVICE_NAME}-${RESOURCE_VERSION}" \
  --description "${RESOURCE_STAGE}-${SERVICE_NAME}-${RESOURCE_VERSION}" \
  --iam-role "service-role/AmazonEC2RunCommandRoleForManagedInstances" \
  --registration-limit 1)

export ACTIVATE_CODE=$(echo ${ACTIVATE_PARAMETERS} | jq -r .ActivationCode)
export ACTIVATE_ID=$(echo ${ACTIVATE_PARAMETERS} | jq -r .ActivationId)
amazon-ssm-agent -register -code "${ACTIVATE_CODE}" -id "${ACTIVATE_ID}" -region "ap-northeast-1" -y
amazon-ssm-agent
