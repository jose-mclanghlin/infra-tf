#!/bin/bash
# Applies Terraform for a specific environment (apply only)

ENV=$1  # development | staging | production

if [ -z "$ENV" ]; then
  echo "Usage: ./apply.sh <environment>"
  exit 1
fi

cd ../environments/$ENV || exit

echo "Applying changes in $ENV"
terraform apply -auto-approve