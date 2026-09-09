# Script Guide

Scripts are owner-operated local helpers. Their behavior is not a substitute for evidence review, and they do not authorize activity outside project-owned lab resources.

| Script | Purpose and phase | Destructive behavior | Prerequisites and security considerations |
| --- | --- | --- | --- |
| `validate.ps1` | Phase 0 local Azure CLI and Terraform connectivity validation. | Non-destructive; runs formatting, init, validation, and plan only. | Azure CLI login, matching `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID`, and Terraform. It never calls apply. |
| `validate-phase2.ps1` | Phase 2 owner-context resource and exact-RBAC validation. | Non-destructive. | Local Terraform state and Azure CLI owner context. Reads only named non-secret outputs and validates storage through Microsoft Entra authentication. |
| `attack-tests.ps1` | Historical Phase 3 controlled harness for AT-01 through AT-05. | AT-03 makes a harmless workload-RG tag mutation and restores it; all other tests are bounded validation actions. | Local Terraform outputs and the live lab were required when Phase 3 ran. The vulnerable environment was destroyed. Do not run this historical harness against the current OIDC deployment; it depends on retired vulnerable-secret outputs. |
| `phase-5-owner-preflight.ps1` | Phase 5 owner-context readiness inspection before OIDC re-attack validation. | Non-destructive; performs only bounded inspection/read operations. | Requires the current lab deployment, local Terraform state, Azure CLI owner context, and Terraform. Verifies known targets, credential absence, federation trust, workload RBAC, and mutation-probe cleanup readiness without executing Phase 5 workload tests. |

## Phase 3 Harness Controls

`attack-tests.ps1` operates only on known project-owned lab resources. It reads the vulnerable secret from Terraform output into memory, uses an isolated temporary `AZURE_CONFIG_DIR`, and performs bounded temporary Azure CLI profile cleanup. It does not publish raw sensitive errors, tokens, or cache contents. AT-03 restores the tag state, and AT-05 expects denial against the negative-control canary.

## Phase 5

Phase 5 harness implementation is in progress. `phase-5-owner-preflight.ps1` provides owner-context readiness inspection, and `.github/workflows/phase-5-oidc-validation.yml` provides the separate manual-only workload OIDC validation harness defined by the [Phase 5 test plan](../docs/attack-path/phase-5-validation-plan.md).

The Phase 5 harness has not been executed. RT-03 and RT-04W remain explicit opt-in mutation probes and must not run together. The historical Phase 3 harness remains unchanged and must not be reused against the current OIDC deployment.

Return to the [project README](../README.md).
