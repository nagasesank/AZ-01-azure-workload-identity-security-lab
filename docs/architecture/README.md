# Architecture Documentation

This area describes AZ-01 workload-identity boundaries, identity-plane and resource-plane design, Azure RBAC, synthetic storage, and security decisions.

- [Phase 1 architecture](phase-1-architecture.md)
- [Security decisions](security-decisions.md)

The verified design separates the workload resource group from a project-owned negative-control resource group and canary. The vulnerable service principal is constrained to the workload boundary. GitHub OIDC, federated identity, and least-privilege remediation are future Phase 4/5 work.

See the [documentation guide](../README.md) for adjacent records.
