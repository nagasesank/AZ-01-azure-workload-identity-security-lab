# Security Decisions

## ADR-001 - Dedicated Lab Resource-Group Boundary

**Decision:** The deliberately vulnerable identity will not receive subscription-wide Owner or Contributor.

**Reason:** A dedicated resource group contains the blast radius while still demonstrating realistic excessive RBAC.

## ADR-002 - Synthetic Data Only

No personal, production, customer, healthcare, credential, or other sensitive data will be used. Future data-plane tests use only synthetic test data.

## ADR-003 - Terraform Remains Source of Truth

Terraform is the authoritative configuration for Azure infrastructure and identity-related resources. Azure Portal is used only for visual verification and evidence.

## ADR-004 - Client Secret Exists Only for the Controlled Vulnerable Phase

The long-lived credential is intentionally temporary. It exists only to support the controlled vulnerable-state validation and must be removed during remediation.

## ADR-005 - GitHub OIDC Is the Target Authentication Architecture

The final implementation uses Microsoft Entra workload identity federation. It must not depend on a persistent Azure client secret stored in GitHub.

## ADR-006 - Project-Owned Negative-Control Boundary

**Decision:** The future AZ-01 project will include a second, project-owned resource group with one benign canary resource. The vulnerable workload service principal receives no role assignment on this negative-control resource group.

**Reason:** AT-05 can prove resource-scope containment through a harmless, known authorization-negative test without enumerating, reading, modifying, or attacking arbitrary resources elsewhere in the subscription. Both resource groups belong to the project, but only the workload-lab resource group is in the compromised identity's authorization boundary.

## ADR-007 - Terraform Provider Ownership Separation

**Decision:** Later implementation will use `hashicorp/azuread` for Microsoft Entra identity objects, including the Entra application, service principal, temporary vulnerable-phase application/client password, and federated identity credential. It will use `hashicorp/azurerm` for Azure resource-plane objects, including resource groups, storage resources, Azure RBAC role assignments, and other Azure resources.

**Reason:** Explicit provider ownership keeps identity-plane and resource-plane configuration clear, reviewable, and Terraform-managed. This decision does not add the `azuread` provider or create any resources in Phase 1.

## ADR-008 - Container-Scoped Read Authorization

**Decision:** The remediated workload identity receives only `Storage Blob Data Reader` at the exact synthetic-data container Resource Manager scope.

**Reason:** The intended workload function is read-only access to synthetic blob data. Management-plane resource enumeration or mutation and write access are not required. Container scope minimizes both the action set and resource scope. The workload identity receives no role assignment on the negative-control resource group.

## ADR-009 - Exact GitHub OIDC Trust Tuple

**Decision:** The Phase 4 federated credential trusts only this tuple:

- Issuer: `https://token.actions.githubusercontent.com`
- Audience: `api://AzureADTokenExchange`
- Subject: `repo:nagasesank@67413218/AZ-01-azure-workload-identity-security-lab@1348063865:ref:refs/heads/main`

**Reason:** The issuer establishes GitHub as the token source, the audience limits token exchange, and the exact immutable subject limits trust to this repository's `main` branch. GitHub's immutable subject format includes stable owner and repository IDs. No repository wildcard, pull-request subject, tag wildcard, environment wildcard, organization-wide trust, or additional branch subject is allowed.

GitHub OIDC federation answers, "Which external workload can obtain a Microsoft Entra token?" Azure RBAC answers, "What can that authenticated principal do?" The Phase 4 remediation requires both independent controls.
