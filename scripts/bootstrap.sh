#!/usr/bin/env bash
#
# Jednorazowe przygotowanie Azure pod Terraform:
#   - Resource Group + Storage Account + Container na plik stanu
#   - Klucz SSH do VM
#
set -euo pipefail
 
set -a
source "$(dirname "$0")/../.env"
set +a
 
RG="rg-${PROJECT_NAME}-tfstate"
SA="st${PROJECT_NAME}tfstate21291" # Nazwa musi być niepowtarzalna
 
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
 
echo ">>> Resource Group: ${RG}"
az group create --name "$RG" --location "$AZURE_LOCATION" --output none
 
echo ">>> Storage Account: ${SA}"
az storage account create \
  --name "$SA" --resource-group "$RG" --location "$AZURE_LOCATION" \
  --sku Standard_LRS --min-tls-version TLS1_2 \
  --allow-blob-public-access false --output none
 
echo ">>> Blob Container: tfstate"
az storage container create \
  --name tfstate --account-name "$SA" --auth-mode login --output none
 
SSH_KEY="$HOME/.ssh/${PROJECT_NAME}"
if [[ ! -f "$SSH_KEY" ]]; then
  echo ">>> Generuję klucz SSH: ${SSH_KEY}"
  ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N "" -C "${PROJECT_NAME}-deploy"
else
  echo ">>> Klucz SSH już istnieje: ${SSH_KEY}"
fi
 
echo ""
echo "Gotowe. Następny krok: bash scripts/create-sp.sh"