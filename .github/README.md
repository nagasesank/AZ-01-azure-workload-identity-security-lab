# GitHub Automation

The `workflows/` directory contains a manual-only Phase 4 OIDC validation workflow. It is configured for a future owner-operated validation window and does not claim successful GitHub OIDC validation or Azure deployment automation. Phase 6 will document broader CI/CD security controls.

The workflow uses GitHub OIDC with repository variables and validates only metadata access to the known synthetic blob. It does not run on push, pull request, or a schedule, and it does not mutate Azure resources.

Return to the [project README](../README.md).
