output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the hub virtual network."
  value       = azurerm_virtual_network.main.id
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster."
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "kube_config" {
  description = "Raw kubeconfig for the AKS cluster. Sensitive — handle accordingly."
  value       = module.aks.kube_config
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace."
  value       = module.monitor.workspace_id
}

output "key_vault_uri" {
  description = "Vault URI of the Key Vault."
  value       = module.hybrid_identity.key_vault_uri
}

output "action_group_id" {
  description = "ID of the monitoring action group."
  value       = module.monitor.action_group_id
}
