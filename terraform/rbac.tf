# The AzureAD replication check is skipped only because this service principal is created in this run.
# The vulnerable assignment is deliberately excessive, but only in the workload-lab boundary.
resource "azurerm_role_assignment" "workload_lab_contributor" {
  scope                            = azurerm_resource_group.workload_lab.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.vulnerable_workload.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "workload_storage_blob_data_contributor" {
  scope                            = azurerm_storage_account.workload_lab.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azuread_service_principal.vulnerable_workload.object_id
  skip_service_principal_aad_check = true
}
