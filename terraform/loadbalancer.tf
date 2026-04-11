###############################################################################
# loadbalancer.tf — Load Balancer przekierowujący port 80 → 8080
#
# Przy jednej VM to nadmiarowe, ale:
#   - wymagane w specyfikacji projektu
#   - gotowe na ewentualne skalowanie
#   - health probe sprawdza czy aplikacja żyje
###############################################################################

resource "azurerm_lb" "app" {
  name                = "lb-${var.project}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.app.id
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
  network_interface_id    = azurerm_network_interface.app.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app.id
}

# Health check — odpytuje Spring Boot Actuator
resource "azurerm_lb_probe" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "health-probe"
  port            = 8080
  protocol        = "Http"
  request_path    = "/actuator/health"
}

# Reguła: ruch na porcie 80 → VM na porcie 8080
resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.app.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}
