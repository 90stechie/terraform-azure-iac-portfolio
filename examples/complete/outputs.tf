output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.example.name
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
