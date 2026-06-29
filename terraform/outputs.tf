output "acr_login_server" {
  description = "URL del servidor de login del ACR"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Usuario administrador del ACR"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Contraseña administrador del ACR"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "vnet_id" {
  description = "ID del Virtual Network"
  value       = azurerm_virtual_network.main.id
}
