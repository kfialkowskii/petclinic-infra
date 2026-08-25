#!/usr/bin/env bash
#
# Tworzy Service Principal dla GitHub Actions z minimalnym zestawem ról:
#   - Reader                     (odczyt wartości infrastruktury przez az CLI)
#   - AcrPush                    (push obrazów Docker do ACR)
#   - Virtual Machine Contributor (az vm run-command invoke podczas wdrożenia)
#
# Zakres: subskrypcja. Przypisanie roli wymaga istniejącego zakresu,
# a ACR i VM powstają dopiero podczas terraform apply.
#
# Wypisuje credentials do wklejenia w GitHub Secrets.
#
set -euo pipefail

set -a
source "$(dirname "$0")/../.env"
set +a

SP_NAME="sp-${PROJECT_NAME}-github"
SUB_SCOPE="/subscriptions/$AZURE_SUBSCRIPTION_ID"

echo ">>> Tworzę Service Principal: ${SP_NAME}"
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Reader \
  --scopes "$SUB_SCOPE" \
  --sdk-auth)

SP_OID=$(az ad sp list --display-name "$SP_NAME" --query "[0].id" -o tsv)

echo ">>> Nadaję AcrPush"
az role assignment create \
  --role AcrPush \
  --assignee-object-id "$SP_OID" --assignee-principal-type ServicePrincipal \
  --scope "$SUB_SCOPE" --output none

echo ">>> Nadaję Virtual Machine Contributor"
az role assignment create \
  --role "Virtual Machine Contributor" \
  --assignee-object-id "$SP_OID" --assignee-principal-type ServicePrincipal \
  --scope "$SUB_SCOPE" --output none

echo ""
echo "============================================"
echo "GITHUB SECRETS — wklej w Settings → Secrets"
echo "============================================"
echo ""
echo "AZURE_CREDENTIALS (cały JSON poniżej):"
echo "$SP_JSON"
echo ""
echo "MYSQL_PASSWORD - hasło z pliku .env"
echo ""
