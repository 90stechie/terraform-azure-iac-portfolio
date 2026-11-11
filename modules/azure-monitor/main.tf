resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

# Single notification target for every alert in this portfolio. Add a
# webhook_receiver or itsm_receiver here to page an on-call rotation.
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  short_name          = "iacalert"
  tags                = var.tags

  email_receiver {
    name          = "ops"
    email_address = var.alert_email
  }
}
