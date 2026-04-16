###############################################################################
# outputs.tf — wartości potrzebne po terraform apply
#
# Użycie: terraform output vm_public_ip
# Potrzebne do: GitHub Secrets, Ansible inventory, deploy scriptu
###############################################################################

output "vm_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "vm_admin_username" {
  value = var.vm_admin_username
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.main.fqdn
}
