resource "azurerm_resource_group" "workload_lab" {
  name     = local.workload_resource_group_name
  location = var.location
  tags     = local.project_tags
}

resource "azurerm_resource_group" "negative_control" {
  name     = local.negative_control_group_name
  location = var.location
  tags     = local.project_tags
}
