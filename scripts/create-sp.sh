#!/usr/bin/env bash
#
# Tworzy Service Principal dla GitHub Actions:
#   - Contributor na subskrypcji (Terraform tworzy zasoby)
#   - Storage Blob Data Contributor (Terraform czyta/zapisuje tfstate)
#   - AcrPush (GitHub Actions pushuje obrazy Docker)
#
# Wypisuje credentials do wklejenia w GitHub Secrets.
#
set -euo pipefail
 
set -a
source "$(dirname "$0")/../.env"
set +a
 
SP_NAME="sp-${PROJECT_NAME}-github"
SUB_SCOPE="/subscriptions/$AZURE_SUBSCRIPTION_ID"
RG_SCOPE="${SUB_SCOPE}/resourceGroups/rg-${PROJECT_NAME}-tfstate"
 
echo ">>> Tworzę Service Principal: ${SP_NAME}"
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Contributor \
  --scopes "$SUB_SCOPE" \
  --sdk-auth)
 
SP_OID=$(az ad sp list --display-name "$SP_NAME" --query "[0].id" -o tsv)
 
echo ">>> Nadaję Storage Blob Data Contributor"
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee-object-id "$SP_OID" --assignee-principal-type ServicePrincipal \
  --scope "$RG_SCOPE" --output none
 
echo ">>> Nadaję AcrPush"
az role assignment create \
  --role AcrPush \
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
echo "ARM_CLIENT_ID=$(echo "$SP_JSON" | jq -r .clientId)"
echo "ARM_CLIENT_SECRET=$(echo "$SP_JSON" | jq -r .clientSecret)"
echo "ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo "ARM_TENANT_ID=$(echo "$SP_JSON" | jq -r .tenantId)"
echo ""
echo "VM_SSH_PRIVATE_KEY → zawartość pliku ~/.ssh/${PROJECT_NAME}"
echo ""
echo "WAŻNE: clientSecret nie da się odzyskać. Zapisz teraz."