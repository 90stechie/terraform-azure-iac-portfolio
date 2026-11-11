variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "centralus"
}

variable "environment" {
  description = "Environment name, used in resource naming and tags (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project" {
  description = "Short project prefix used in resource names."
  type        = string
  default     = "iac"
}

variable "tags" {
  description = "Common tags applied to every resource."
  type        = map(string)
  default = {
    Project   = "iac-portfolio"
    ManagedBy = "terraform"
  }
}

variable "address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.0.0.0/22"
}

variable "pe_subnet_prefix" {
  description = "Address prefix for the private-endpoint subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Leave empty to use the latest supported version."
  type        = string
  default     = ""
}

variable "system_node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_vm_size" {
  description = "VM size for the AKS user node pool."
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

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address for the monitoring action group."
  type        = string
  default     = "ops@example.com"
}

variable "aks_admin_group_name" {
  description = "Entra ID group name for AKS cluster admins."
  type        = string
  default     = "aks-admins"
}
