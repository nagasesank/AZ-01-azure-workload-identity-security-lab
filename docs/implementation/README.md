# Implementation Documentation

- [Phase 2 deployment and state security](phase-2-deployment.md)
- [Phase 4 secretless OIDC and least-privilege remediation](phase-4-remediation.md)

Phase 2 contains the verified vulnerable implementation record. The associated infrastructure was destroyed after Phase 3 evidence capture.

Phase 4 removed the client password from the Terraform design, configured GitHub OIDC federation, and reduced workload authorization to container-scoped read access. Owner-operated runtime validation of OIDC authentication and the intended synthetic-blob metadata read completed successfully on 2026-09-09.

Post-remediation denied-access and re-attack tests remain Phase 5 work.

Return to the [documentation guide](../README.md).
