# Terraform Guide

Terraform is the configuration source of truth for AZ-01. The Phase 2/3 vulnerable lab resources were intentionally destroyed after testing; Phase 4 remediation has not started.

## Configuration

- Terraform version: `>= 1.10.0`.
- Providers: `hashicorp/azurerm` (`~> 4.0`), `hashicorp/azuread` (`~> 3.0`), and `hashicorp/random` (`~> 3.0`).
- AzureRM manages resource-plane objects such as resource groups, storage, and RBAC assignments.
- AzureAD manages the Microsoft Entra application, service principal, and temporary vulnerable-phase password.
- Random provides the generated storage-account suffix.

The configuration defines project-owned workload and negative-control resource groups, a private synthetic-data storage path, a benign canary identity, and deliberately vulnerable lab-scoped role assignments. Output values include named resources and sensitive authentication context or temporary credential values. Do not print, publish, or commit sensitive output values.

## Local Authentication and Workflow

Use an existing Azure CLI `az login` session. `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` must match the active Azure CLI account. The only Terraform input variable is the deployment location, with an example in `terraform.tfvars.example`.

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Terraform apply and destroy are owner-operated actions. Never commit Terraform state, generated plans, `.tfvars` files containing real data, credentials, or provider cache content. Do not use sensitive outputs as documentation examples.

See [scripts/README.md](../scripts/README.md) for the corresponding local validation helpers and return to the [project README](../README.md).
