# Script Guide

Scripts are owner-operated local helpers. Their behavior is not a substitute for evidence review, and they do not authorize activity outside project-owned lab resources.

| Script | Purpose and phase | Destructive behavior | Prerequisites and security considerations |
| --- | --- | --- | --- |
| `validate.ps1` | Phase 0 local Azure CLI and Terraform connectivity validation. | Non-destructive; runs formatting, init, validation, and plan only. | Azure CLI login, matching `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID`, and Terraform. It never calls apply. |
| `validate-phase2.ps1` | Phase 2 owner-context resource and exact-RBAC validation. | Non-destructive. | Local Terraform state and Azure CLI owner context. Reads only named non-secret outputs and validates storage through Microsoft Entra authentication. |
| `attack-tests.ps1` | Historical Phase 3 controlled harness for AT-01 through AT-05. | AT-03 makes a harmless workload-RG tag mutation and restores it; all other tests are bounded validation actions. | Local Terraform outputs and the live lab were required when Phase 3 ran. The vulnerable environment was destroyed. Do not run this historical harness against later deployments; it depends on retired vulnerable-secret outputs. |
| `phase-5-owner-preflight.ps1` | Historical Phase 5 owner-context readiness inspection before OIDC re-attack validation. | Non-destructive; performs only bounded inspection/read operations. | Required the later Phase 4/5 validation deployment, local Terraform state, Azure CLI owner context, and Terraform. That deployment has now been destroyed. |

## Phase 3 Harness Controls

`attack-tests.ps1` operates only on known project-owned lab resources. It reads the vulnerable secret from Terraform output into memory, uses an isolated temporary `AZURE_CONFIG_DIR`, and performs bounded temporary Azure CLI profile cleanup. It does not publish raw sensitive errors, tokens, or cache contents. AT-03 restores the tag state, and AT-05 expects denial against the negative-control canary.

## Phase 5

On 2026-09-09, `phase-5-owner-preflight.ps1` completed PF-01 through PF-06 successfully. The manual GitHub OIDC validation harness in `.github/workflows/phase-5-oidc-validation.yml` completed RT-01 through RT-06 (including RT-04R and RT-04W) across three bounded reviewed dispatches defined by the [Phase 5 test plan](../docs/attack-path/phase-5-validation-plan.md). RT-03 and RT-04W were executed separately, and cleanup passed in all three runs. See the [Phase 5 runtime validation evidence](../docs/evidence/phase-5-runtime-validation.md) for individual results and limits.

RT-03 and RT-04W were explicit opt-in mutation probes and did not run together. Credential absence was verified by configuration inspection, not retired-secret replay testing. Historical Phase 3 `attack-tests.ps1` remains retired and must not be reused because it relies on retired vulnerable-secret outputs.

The Phase 4/5 validation deployment has now been destroyed, bounded cleanup verification is complete, and the Phase 5 GitHub repository secrets were removed. See the [Phase 7 teardown validation](../docs/evidence/phase-7-teardown-validation.md). Phase 6 CI/CD security controls remain future work.

Return to the [project README](../README.md).
