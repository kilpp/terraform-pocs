output "storage-account-id" {
  description = "The id of the storage account"
  value       = azurerm_storage_account.terraform-storage-account.id
}

output "storage-account-access-key" {
  description = "Primary Access Key to Storage Account"
  value       = azurerm_storage_account.terraform-storage-account.primary_access_key
  sensitive   = true
}