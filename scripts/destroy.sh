#!/bin/bash
# Destroys Terraform resources in a specific environment

ENV=$1  # development | qa | staging | production

if [ -z "$ENV" ]; then
  echo "Usage: ./destroy.sh <environment>"
  exit 1
fi

cd ../environments/$ENV || exit

echo "Destroying resources in $ENV"
terraform destroy -auto-approve