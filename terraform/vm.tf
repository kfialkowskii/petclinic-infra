###############################################################################
# vm.tf — maszyna wirtualna z publicznym IP i Managed Identity
#
# Managed Identity pozwala VM logować się do ACR bez haseł.
# Azure CLI na VM robi "az login --identity" i ma dostęp do zasobów
# bez przechowywania jakichkolwiek credentials.
###############################################################################

resource "azurerm_public_ip" "app" {
  name                = "pip-${var.project}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "app" {
  name                = "nic-${var.project}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app.id
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                  = "vm-${var.project}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.app.id]

  # Managed Identity — VM dostaje tożsamość w Azure AD
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
