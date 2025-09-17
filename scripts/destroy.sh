#!/bin/bash
# Destruye recursos Terraform en un environment específico

ENV=$1

if [ -z "$ENV" ]; then
  echo "Uso: ./destroy.sh <environment>"
  exit 1
fi

cd ../environments/$ENV || exit

echo "Destruyendo recursos en $ENV"
terraform destroy -auto-approve