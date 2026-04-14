###############################################################################
# main.tf — Resource Group, wspólny kontener na wszystkie zasoby projektu
###############################################################################

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}"
  location = var.location

}
