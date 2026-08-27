resource "random_string" "storage_suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "workload_lab" {
  name                     = "staz01${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.workload_lab.name
  location                 = azurerm_resource_group.workload_lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  tags = local.project_tags
}

resource "azurerm_storage_container" "synthetic_data" {
  name                  = "synthetic-data"
  storage_account_id    = azurerm_storage_account.workload_lab.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.operator_storage_blob_data_contributor]
}

resource "azurerm_storage_blob" "synthetic_data" {
  name                 = "az01-synthetic-data.txt"
  storage_account_name = azurerm_storage_account.workload_lab.name
  storage_container_id = azurerm_storage_container.synthetic_data.id
  type                 = "Block"
  source_content       = "AZ-01 synthetic workload identity security test data. No production, personal, customer, healthcare, or confidential data."
}
