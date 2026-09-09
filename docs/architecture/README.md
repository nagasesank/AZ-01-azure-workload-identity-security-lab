# Architecture Documentation

This area describes AZ-01 workload-identity boundaries, identity-plane and resource-plane design, Azure RBAC, synthetic storage, and security decisions.

- [Phase 1 architecture](phase-1-architecture.md)
- [Security decisions](security-decisions.md)

The verified design separates the workload resource group from a project-owned negative-control resource group and canary. Phase 4 prepares a GitHub OIDC federated credential and container-scoped read authorization; runtime validation is pending. Phase 5 remains future re-attack work.

See the [documentation guide](../README.md) for adjacent records.
