#!/bin/bash
# Inicializa Terraform para un environment específico
ENV=$1  # development | staging | production

if [ -z "$ENV" ]; then
  echo "Uso: ./init.sh <environment>"
  exit 1
fi

cd ../environments/$ENV || exit

echo "Inicializando Terraform en el environment: $ENV"
terraform init -reconfigure
