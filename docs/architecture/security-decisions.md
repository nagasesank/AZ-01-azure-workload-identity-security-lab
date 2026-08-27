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
