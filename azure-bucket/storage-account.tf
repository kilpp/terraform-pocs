resource "azurerm_resource_group" "terraform-resource-group" {
  name     = var.resource-group-name
  location = var.location

  tags = local.common_tags
}

resource "azurerm_storage_account" "terraform-storage-account" {
  name                     = var.storage-account-name
  resource_group_name      = azurerm_resource_group.terraform-resource-group.name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = local.common_tags
}

resource "azurerm_storage_container" "terraform-storage-container" {
  name                 = var.container-name
  storage_account_name = azurerm_storage_account.terraform-storage-account.name
}