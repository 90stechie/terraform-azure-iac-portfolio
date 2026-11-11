variable "location" {
  description = "Azure region for the workspace and action group."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the workspace and action group."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used in resource names, e.g. iac-dev."
  type        = string
}

variable "retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address for the monitoring action group."
  type        = string
}

variable "tags" {
  description = "Tags applied to the monitoring resources."
  type        = map(string)
  default     = {}
}
