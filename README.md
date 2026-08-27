# Azure Workload Identity Attack & Secretless Federation Lab

Terraform-first lab scaffold for exploring Azure workload identity risks, federation patterns, and secretless authentication workflows without deploying any Azure resources in Phase 0.

## Architecture

Placeholder for the lab architecture, trust boundaries, and identity flow diagrams.

## Threat Model

Placeholder for threat actors, assumptions, attack preconditions, and defensive controls.

## Project Phases

1. Phase 0: Local repository foundation and Azure connectivity validation only.
2. Phase 1: Model target identity flows and document attack paths.
3. Phase 2: Introduce controlled lab infrastructure with Terraform.
4. Phase 3: Exercise attack simulations and capture evidence.
5. Phase 4: Add detections, hardening guidance, and cleanup procedures.

## Local Prerequisites

- Terraform `>= 1.10`
- Azure CLI installed
- An existing Azure CLI session established with `az login`
- Permission to read the intended Azure subscription and tenant context

## Phase 0 Connectivity Validation

These commands validate local tooling and authenticated context only. They do not deploy resources.

```powershell
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out phase0.tfplan
az account show --output table
az account tenant list --output table
```

Do not assume connectivity is working until the commands above succeed in your environment.

## Credential Safety

Never commit credentials, tokens, client secrets, certificates, `.tfstate` files, local override files, or environment files to this repository.
