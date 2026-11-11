output "admin_group_object_id" {
  description = "Object ID of the AKS admin Entra ID group."
  value       = azuread_group.aks_admins.object_id
}

output "key_vault_id" {
  description = "ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Vault URI of the Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.main.name
}

output "automation_sp_object_id" {
  description = "Object ID of the automation service principal."
  value       = azuread_service_principal.automation.object_id
}

output "workload_identity_id" {
  description = "ID of the workload user-assigned managed identity."
  value       = azurerm_user_assigned_identity.workload.id
}
