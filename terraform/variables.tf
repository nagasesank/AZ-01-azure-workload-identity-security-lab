# Authentication comes from the local Azure CLI session and ARM_* environment variables.
# Subscription and tenant values are intentionally not Terraform input variables.

variable "location" {
  description = "Azure region for the project-owned Phase 2 lab resources."
  type        = string
  default     = "eastus"
}
