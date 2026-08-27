provider "azurerm" {
  features {}

  # Use Microsoft Entra authorization for storage data-plane API calls.
  storage_use_azuread = true
}

# AzureAD uses the same local Azure CLI authentication context as AzureRM.
provider "azuread" {}
