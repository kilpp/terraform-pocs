variable "location" {
  description = "Region where the resources will be created on Azure"
  type        = string
  default     = "Brazil South"
}

variable "account_tier" {
  description = "Tier of the storage account on Azure"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Type of replication of the storage account"
  type        = string
  default     = "LRS"
}

variable "resource-group-name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-terraform-gk"
}

variable "storage-account-name" {
  description = "The name of the storage account"
  type        = string
  default     = "saterraformgk"
}

variable "container-name" {
  description = "The name of the container"
  type        = string
  default     = "container-terraform-gk"
}