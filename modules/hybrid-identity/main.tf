data "azurerm_client_config" "current" {}

# Admin group for the AKS cluster — cluster admin follows group membership,
# so access is revoked by removing someone from the group.
resource "azuread_group" "aks_admins" {
  display_name     = var.admin_group_name
  security_enabled = true
  owners           = [data.azurerm_client_config.current.object_id]
}

# Service principal used by automation (CI/CD, scripts). Its secret is
# created here for the portfolio; in production, prefer federated
# credentials (workload identity federation) over a stored secret.
resource "azuread_application" "automation" {
  display_name = "sp-${var.name_prefix}-automation"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "automation" {
  client_id = azuread_application.automation.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "automation" {
  service_principal_id = azuread_service_principal.automation.id
  end_date_relative    = "8760h" # 1 year
}

# Key Vault names must be globally unique, so a short random suffix is
# appended. The vault is private by default: public access denied, and a
# private endpoint is created in the supplied subnet.
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_key_vault" "main" {
  name                       = "kv${replace(var.name_prefix, "-", "")}${random_string.suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }

  tags = var.tags
}

# Least-privilege role assignments, scoped to this vault only.
resource "azurerm_role_assignment" "admin_group_vault_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_group.aks_admins.object_id
}

resource "azurerm_role_assignment" "automation_vault_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_service_principal.automation.object_id
}

# Managed identity for workloads (pod identity / workload identity) that
# need to read secrets without a stored credential.
resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-${var.name_prefix}-workload"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "workload_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

# Private DNS so the vault resolves to its private IP inside the VNet.
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "link-kv-${var.name_prefix}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-kv-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  tags = var.tags
}
