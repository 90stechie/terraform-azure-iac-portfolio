variable "location" {
  description = "Azure region for the cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the cluster."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used in resource names, e.g. iac-dev."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Empty means the latest supported version."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "ID of the subnet the node pools live in."
  type        = string
}

variable "system_node_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_vm_size" {
  description = "VM size for the user node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_min_count" {
  description = "Minimum nodes in the user node pool."
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "Maximum nodes in the user node pool."
  type        = number
  default     = 5
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for container insights and diagnostics."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Entra ID group object IDs granted AKS cluster admin."
  type        = list(string)
  default     = []
}

variable "key_vault_id" {
  description = "ID of the Key Vault the kubelet identity may read secrets from."
  type        = string
}

variable "tags" {
  description = "Tags applied to the cluster resources."
  type        = map(string)
  default     = {}
}
