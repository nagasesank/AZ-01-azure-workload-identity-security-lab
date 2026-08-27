# AZ-01 - Azure Workload Identity Attack & Secretless Federation Lab

> Attack workload identity. Remove long-lived secrets. Prove least privilege.

## Project Overview

An Azure security engineering lab designed to demonstrate how long-lived workload credentials and excessive Azure RBAC permissions create exploitable identity attack paths, then remove those risks using Microsoft Entra workload identity federation, GitHub OIDC, and least-privilege authorization, with Terraform as the infrastructure source of truth.

## Security Problem

Long-lived workload secrets can be copied, replayed, and difficult to rotate. When paired with excessive Azure RBAC permissions, they can provide an attacker with durable, high-impact access.

## Project Objectives

- Model a controlled workload-identity attack path.
- Demonstrate the effect of excessive authorization in an isolated lab.
- Replace long-lived credentials with workload identity federation.
- Verify that least-privilege access denies unauthorized actions.

## Planned Architecture

Architecture diagrams, trust boundaries, identity flows, and Terraform-managed components will be documented in `docs/architecture/` before infrastructure is introduced.

## Threat Model

Threat actors, assumptions, attack preconditions, and defensive controls will be documented in `docs/threat-model/`.

## Attack -> Remediation Lifecycle

```text
Long-lived secret
      |
Service Principal
      |
Overprivileged Azure RBAC
      |
Controlled credential abuse
      |
Excessive access demonstrated
      |
Remove long-lived credential
      |
GitHub OIDC federation
      |
Scoped least-privilege RBAC
      |
Repeat access tests
      |
Unauthorized actions denied
```

## Project Phases

1. Phase 0: Repository and Azure connectivity.
2. Phase 1: Architecture and threat modeling.
3. Phase 2: Vulnerable identity infrastructure.
4. Phase 3: Credential-compromise attack validation.
5. Phase 4: GitHub OIDC and least-privilege remediation.
6. Phase 5: Re-attack and security validation.
7. Phase 6: CI/CD security controls.
8. Phase 7: Evidence, cleanup, and retrospective.

## Technology Stack

- Terraform and the AzureRM provider
- Azure CLI for local authentication
- Microsoft Entra workload identity federation
- GitHub OIDC in a later phase
- PowerShell for local validation and controlled test orchestration

## Repository Structure

```text
docs/       Design, threat-model, attack-path, and evidence records
scripts/    Local validation and future controlled attack-test helpers
terraform/  Terraform configuration and provider lock file
```

## Local Prerequisites

- Terraform `>= 1.10.0`
- Azure CLI
- An existing `az login` session with access to the intended subscription
- PowerShell

## Phase 0 - Local Terraform Connectivity Validation

Phase 0 validates only the local authenticated Azure context. It does not deploy or apply infrastructure.

```powershell
az account show --output table

$env:ARM_SUBSCRIPTION_ID = az account show --query id -o tsv
$env:ARM_TENANT_ID = az account show --query tenantId -o tsv

cd terraform

terraform init
terraform fmt -check
terraform validate
terraform plan -input=false
```

The AzureRM provider uses the existing Azure CLI session and supports `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID`. A successful Phase 0 plan should report no infrastructure changes:

```text
0 to add
0 to change
0 to destroy
```

Local Phase 0 validation has successfully demonstrated the Azure CLI authenticated context, Terraform initialization and configuration validation, AzureRM provider connectivity, a successful `azurerm_client_config` lookup, and zero real infrastructure changes. `scripts/validate.ps1` runs the same non-destructive checks and never calls `terraform apply`.

## Phase 2 - Verified Vulnerable Lab Implementation

Phase 2 deployed the deliberately vulnerable, lab-only workload identity and completed owner-context validation successfully. The verified configuration includes a temporary client password, an excessive Contributor role limited to the workload-lab resource group, synthetic blob data, and a project-owned negative-control canary with no workload service-principal access. It uses only a minimal Standard LRS storage account and tiny synthetic blob; no virtual machines, premium services, or diagnostic workspaces are used. The credential is temporary, must be treated as sensitive in Terraform state, and is removed in Phase 4. Phase 3 attack tests have not started.

## Security / Credential Handling

Never commit `ARM_CLIENT_SECRET`, service principal passwords, Azure access tokens, GitHub tokens, Azure CLI token/cache files, real `.env` files, or Terraform state files. Do not commit subscription IDs, tenant IDs, client IDs, object IDs, credentials, or other secret material. Commit `.terraform.lock.hcl` so provider versions are reproducible.

## Evidence Strategy

Only verified outputs from controlled validation are retained in `docs/evidence/`. Evidence excludes screenshots, identifiers, credentials, tokens, Terraform state, and deployment-sensitive values.

## Cost-Control Strategy

Phase 0 creates no Azure resources. Later resources will be deployed only during controlled validation windows and removed with `terraform destroy` after testing. High-cost Azure services must not remain running. This project is designed for a constrained Azure lab-credit environment and intentionally contains no fabricated cost estimates.

## Current Project Status

```text
Phase 0: Complete
Phase 1: Complete
Phase 2: Complete
Phase 3: Not Started
```
