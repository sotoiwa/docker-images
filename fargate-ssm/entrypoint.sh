#!/bin/bash

set -eux
set -o pipefail

env

amazon-ssm-agent -register -id "${ACTIVATION_ID}" -code "${ACTIVATION_CODE}" -region "${AWS_REGION}"
amazon-ssm-agent
