# Script Guide

Scripts are owner-operated local helpers. Their behavior is not a substitute for evidence review, and they do not authorize activity outside project-owned lab resources.

| Script | Purpose and phase | Destructive behavior | Prerequisites and security considerations |
| --- | --- | --- | --- |
| `validate.ps1` | Phase 0 local Azure CLI and Terraform connectivity validation. | Non-destructive; runs formatting, init, validation, and plan only. | Azure CLI login, matching `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID`, and Terraform. It never calls apply. |
| `validate-phase2.ps1` | Phase 2 owner-context resource and exact-RBAC validation. | Non-destructive. | Local Terraform state and Azure CLI owner context. Reads only named non-secret outputs and validates storage through Microsoft Entra authentication. |
| `attack-tests.ps1` | Historical Phase 3 controlled harness for AT-01 through AT-05. | AT-03 makes a harmless workload-RG tag mutation and restores it; all other tests are bounded validation actions. | Local Terraform outputs and the live lab were required when Phase 3 ran. The current lab is destroyed, so it must not be run without a future approved validation window. |

## Phase 3 Harness Controls

`attack-tests.ps1` operates only on known project-owned lab resources. It reads the vulnerable secret from Terraform output into memory, uses an isolated temporary `AZURE_CONFIG_DIR`, and performs bounded temporary Azure CLI profile cleanup. It does not publish raw sensitive errors, tokens, or cache contents. AT-03 restores the tag state, and AT-05 expects denial against the negative-control canary.

Return to the [project README](../README.md).
