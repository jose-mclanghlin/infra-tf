#!/bin/bash
# Aplica Terraform para un environment específico

ENV=$1  # development | staging | production

if [ -z "$ENV" ]; then
  echo "Uso: ./apply.sh <environment>"
  exit 1
fi

cd ../environments/$ENV || exit

echo "Ejecutando plan en $ENV"
terraform plan -out=tfplan

echo "Aplicando cambios en $ENV"
terraform apply -auto-approve tfplan
