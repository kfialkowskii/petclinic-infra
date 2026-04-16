###############################################################################
# database.tf - Azure Database for MySQL Flexible Server
#
# Baza w prywatnym subnecie (snet-db) - brak publicznego dostępu.
# Komunikacja z VM odbywa się przez VNet + Private DNS Zone.
###############################################################################

# DNS - żeby VM mogła znaleźć bazę po nazwie (FQDN) wewnątrz VNetu
resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.project}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Sam serwer MySQL
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${var.project}"
  location               = azurerm_resource_group.main.location
  resource_group_name    = azurerm_resource_group.main.name
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms" # najtańszy tier
  version                = "8.0.21"
  zone                   = "3"

  # Prywatny dostęp — baza siedzi w snet-db, niedostępna z internetu
  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  storage {
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

# Baza danych dla aplikacji
resource "azurerm_mysql_flexible_database" "petclinic" {
  name                = "petclinic"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
