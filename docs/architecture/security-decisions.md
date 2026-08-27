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
