locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Environment = var.environment })
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aks_subnet_prefix]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.pe_subnet_prefix]
}

module "hybrid_identity" {
  source = "./modules/hybrid-identity"

  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name_prefix         = local.name_prefix
  vnet_id             = azurerm_virtual_network.main.id
  pe_subnet_id        = azurerm_subnet.private_endpoints.id
  admin_group_name    = var.aks_admin_group_name
  tags                = local.common_tags
}

module "monitor" {
  source = "./modules/azure-monitor"

  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name_prefix         = local.name_prefix
  retention_days      = var.log_retention_days
  alert_email         = var.alert_email
  tags                = local.common_tags
}

module "aks" {
  source = "./modules/aks"

  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  name_prefix                = local.name_prefix
  kubernetes_version         = var.kubernetes_version
  subnet_id                  = azurerm_subnet.aks.id
  system_node_vm_size        = var.system_node_vm_size
  user_node_vm_size          = var.user_node_vm_size
  user_node_min_count        = var.user_node_min_count
  user_node_max_count        = var.user_node_max_count
  log_analytics_workspace_id = module.monitor.workspace_id
  admin_group_object_ids     = [module.hybrid_identity.admin_group_object_id]
  key_vault_id               = module.hybrid_identity.key_vault_id
  tags                       = local.common_tags
}

# AKS health alerts, wired up here so the monitor module stays free of a
# dependency cycle (the AKS module needs the workspace ID, and the alerts
# need the cluster ID).
resource "azurerm_monitor_metric_alert" "aks_node_cpu" {
  name                = "alert-aks-node-cpu-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [module.aks.cluster_id]
  description         = "Average node CPU usage above 80% for 15 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = module.monitor.action_group_id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "aks_node_memory" {
  name                = "alert-aks-node-memory-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [module.aks.cluster_id]
  description         = "Average node memory working set above 85% for 15 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = module.monitor.action_group_id
  }

  tags = local.common_tags
}
