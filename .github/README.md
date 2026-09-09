# GitHub Automation

The `workflows/` directory contains the manual Phase 4/5 OIDC validation workflow used for the bounded runtime validation documented by this repository. The workflow successfully exercised GitHub OIDC authentication and the reviewed Phase 5 authorization checks against the later secretless validation deployment.

The workflow is manual-only and does not run on push, pull request, or a schedule. Its validated scope is limited to the known project-owned targets and bounded checks recorded in the Phase 4 and Phase 5 evidence; it is not Azure deployment automation and does not establish universal authorization behavior.

After Phase 5 evidence review and Terraform teardown, the Phase 5 repository secrets used to supply the Azure identifiers to the workflow were removed and verified absent. The teardown record is in [Phase 7 teardown validation](../docs/evidence/phase-7-teardown-validation.md).

Phase 6 will address broader CI/CD security controls. That work has not started yet.

Return to the [project README](../README.md).
