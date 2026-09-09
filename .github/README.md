# GitHub Automation

The `workflows/` directory contains the manual Phase 4/5 OIDC validation workflow used for the bounded runtime validation documented by this repository. The workflow successfully exercised GitHub OIDC authentication and the reviewed Phase 5 authorization checks against the later secretless validation deployment.

The workflow is manual-only and does not run on push, pull request, or a schedule. Its validated scope is limited to the known project-owned targets and bounded checks recorded in the Phase 4 and Phase 5 evidence; it is not Azure deployment automation and does not establish universal authorization behavior.

After Phase 5 evidence review and Terraform teardown, the Phase 5 repository secrets used to supply the Azure identifiers to the workflow were removed and verified absent. The teardown record is in [Phase 7 teardown validation](../docs/evidence/phase-7-teardown-validation.md).

The [Phase 6 CI/CD security controls plan](../docs/implementation/phase-6-cicd-security-plan.md) is prepared; implementation and validation remain pending. This documentation-only change creates no CI workflow, ruleset, or security setting. The plan preserves historical Phase 4/5 workflow source and proposes owner-operated disablement after implementation review, plus exact stale Phase 4 variable cleanup after owner review. Planning has no Azure runtime dependency.

Return to the [project README](../README.md).
