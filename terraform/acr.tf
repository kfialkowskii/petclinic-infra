###############################################################################
# acr.tf — Azure Container Registry + uprawnienia
#
# admin_enabled = false — żadnych haseł w obiegu.
# Kto ma dostęp:
#   - Service Principal (GitHub Actions) → AcrPush — pushuje obrazy
#   - Managed Identity VM               → AcrPull — pobiera obrazy
###############################################################################

resource "azurerm_container_registry" "main" {
  name                = "acr${var.project}21291"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

# VM może pullować obrazy z ACR
resource "azurerm_role_assignment" "vm_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_virtual_machine.app.identity[0].principal_id
}
