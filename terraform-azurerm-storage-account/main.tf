## define locals, modules, resources etc. here
# create storage account
resource "azurecaf_name" "storage-account-name" {  
  resource_type    = "azurerm_storage_account"
  random_length   = 22
}

resource "azurerm_storage_account" "storage-account" {
  name                     = azurecaf_name.storage-account-name.result
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  tags = var.tags
}