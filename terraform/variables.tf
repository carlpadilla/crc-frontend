variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for frontend resources"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources into"
  default     = "eastus"
}

variable "domain_name" {
  type        = string
  description = "Root domain (e.g., carlpadilla.com)"
}

variable "cdn_hostname" {
  type        = string
  description = "Prefix for the CDN Front Door endpoint"
  default     = "resume"
}
