variable "location" {
  description = "Azure region for the identity resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the identity resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used in resource names, e.g. iac-dev."
  type        = string
}

variable "vnet_id" {
  description = "ID of the virtual network for the private DNS zone link."
  type        = string
}

variable "pe_subnet_id" {
  description = "ID of the subnet for the Key Vault private endpoint."
  type        = string
}

variable "admin_group_name" {
  description = "Entra ID group name for AKS cluster admins."
  type        = string
  default     = "aks-admins"
}

variable "tags" {
  description = "Tags applied to the identity resources."
  type        = map(string)
  default     = {}
}
