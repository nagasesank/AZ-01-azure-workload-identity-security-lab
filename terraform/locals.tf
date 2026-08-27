locals {
  project_tags = {
    project     = "AZ-01"
    environment = "lab"
    managed-by  = "terraform"
    purpose     = "workload-identity-security"
  }

  workload_resource_group_name = "rg-az01-workload-lab"
  negative_control_group_name  = "rg-az01-negative-control"
}
