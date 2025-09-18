#!/bin/bash
# Initializes Terraform for a specific environment

ENV=$1  # development | qa | staging | production

if [ -z "$ENV" ]; then
  echo "Usage: ./init.sh <environment>"
  exit 1
fi

cd ../environments/$ENV || exit

echo "Initializing Terraform in environment: $ENV"
terraform init -reconfigure