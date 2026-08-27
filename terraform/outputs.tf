output "current_subscription_id" {
  description = "The subscription ID for the current authenticated Azure context."
  value       = data.azurerm_client_config.current.subscription_id
  sensitive   = true
}

output "current_tenant_id" {
  description = "The tenant ID for the current authenticated Azure context."
  value       = data.azurerm_client_config.current.tenant_id
  sensitive   = true
}

output "current_client_id" {
  description = "The authenticated client or application ID when available from the current Azure context."
  value       = data.azurerm_client_config.current.client_id
  sensitive   = true
}

output "current_object_id" {
  description = "The authenticated object ID when available from the current Azure context."
  value       = data.azurerm_client_config.current.object_id
  sensitive   = true
}

output "workload_resource_group_name" {
  description = "Name of the project-owned workload-lab resource group."
  value       = azurerm_resource_group.workload_lab.name
}

output "negative_control_resource_group_name" {
  description = "Name of the project-owned negative-control resource group."
  value       = azurerm_resource_group.negative_control.name
}

output "workload_storage_account_name" {
  description = "Name of the storage account holding synthetic test data."
  value       = azurerm_storage_account.workload_lab.name
}

output "synthetic_data_container_name" {
  description = "Name of the private container holding synthetic data."
  value       = azurerm_storage_container.synthetic_data.name
}

output "negative_control_canary_name" {
  description = "Name of the project-owned canary with no workload identity access."
  value       = azurerm_user_assigned_identity.negative_control_canary.name
}

output "vulnerable_application_client_id" {
  description = "Client ID for later controlled authentication testing."
  value       = azuread_application.vulnerable_workload.client_id
}

output "vulnerable_client_secret" {
  description = "Temporary vulnerable-phase password. Terraform state containing this value is sensitive."
  value       = azuread_application_password.vulnerable_workload.value
  sensitive   = true
}
