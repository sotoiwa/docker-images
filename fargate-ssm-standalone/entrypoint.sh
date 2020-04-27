#!/bin/bash

set -eux
set -o pipefail

env

activation=$(aws ssm create-activation \
  --default-instance-name "DockerSSM" \
  --iam-role "SSMServiceRole" \
  --registration-limit 1)
activation_id=$(echo ${activation} | jq -r .ActivationId)
activation_code=$(echo ${activation} | jq -r .ActivationCode)

amazon-ssm-agent -register -id "${activation_id}" -code "${activation_code}" -region "${AWS_REGION}"
amazon-ssm-agent
