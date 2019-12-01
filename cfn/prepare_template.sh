#!/bin/bash

set -o errexit

account_id="$(aws sts get-caller-identity --query Account --output text | xargs echo -n)"
echo using account ${account_id} in ${AWS_DEFAULT_REGION}
sed -e "s/REGION/${AWS_DEFAULT_REGION}/g" -e "s/ACCOUNT_ID/${account_id}/g" api-template.yml > api.yml