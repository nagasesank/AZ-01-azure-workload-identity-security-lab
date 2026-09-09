# Phase 4 Runtime Validation

## Validation Record

On 2026-09-09, the manual **Phase 4 OIDC Validation** workflow completed successfully on the repository's `main` branch. The run used the workflow definition committed on `main` after the immutable GitHub OIDC subject remediation was merged.

The following assertions are verified from the completed GitHub Actions job:

| Assertion | Result | Evidence |
| --- | --- | --- |
| GitHub-issued OIDC token exchanged for an Azure CLI session | PASS | The OIDC authentication step and the explicit sanitized authentication marker completed successfully. |
| Federated workload identity could read metadata for the known synthetic blob | PASS | The metadata-only `az storage blob show` step completed successfully with Microsoft Entra authentication and emitted the sanitized authorization marker. |
| Azure CLI session cleanup ran | PASS | The always-run logout step and post-authentication cleanup completed successfully. |
| Workflow completed without an uploaded evidence artifact | PASS | The run reported no artifacts; raw logs are intentionally not copied into the repository. |

## Screenshot Inventory

| Screenshot | What it shows |
| --- | --- |
| [01-oidc-workflow-success.png](screenshots/phase-4/01-oidc-workflow-success.png) | The manual Phase 4 OIDC Validation run on `main` completed successfully, including GitHub OIDC authentication, authentication confirmation, known synthetic-blob read validation, Azure CLI logout, and post-authentication cleanup. |

This image is a crop of the owner's `phase-4-github-oidc-validation-success.png` capture. Cropping removes local shell paths and surrounding command output; retained result pixels are unchanged. One image covers the successful run and its named steps. Public GitHub Actions run/job references remain for traceability; they are not Azure identifiers or immutable repository/owner IDs. No raw workflow-log file is included.

## Security Interpretation

This run verifies secretless GitHub OIDC authentication and intended read access to the known private synthetic blob. The validation command did not print blob contents and did not mutate Azure resources.

This result does **not** by itself prove denial of management-plane access, write operations, broader storage access, or negative-control access. Those post-remediation authorization tests remain Phase 5 work and must use only known project-owned resources.

## Evidence Hygiene

The public record intentionally excludes raw workflow logs because action input expansion can contain repository-variable values and Azure identifiers. No client IDs, tenant IDs, subscription IDs, object or principal IDs, storage-account names, federated tokens, credentials, Terraform state, or sensitive values are reproduced here.

The authoritative runtime source is the successful GitHub Actions run retained in the repository Actions history. Its public-safe facts are the workflow name, manual trigger, `main` branch, 2026-09-09 execution date, successful job conclusion, and successful named steps recorded above.

## Baseline Separation

[Phase 3 evidence](phase-3.md) remains the immutable pre-remediation credential-compromise baseline. This Phase 4 record is separate remediation-runtime evidence and does not rewrite or reinterpret the Phase 3 results.
