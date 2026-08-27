provider "azurerm" {
  features {}
}

# AzureAD uses the same local Azure CLI authentication context as AzureRM.
provider "azuread" {}
