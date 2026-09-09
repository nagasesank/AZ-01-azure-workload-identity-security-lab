# Phase 5 Post-Remediation Validation Plan

Status: planning started; harness implementation and runtime execution pending.

## Baseline and Identity Boundary

Phase 3 remains the immutable vulnerable-state baseline. Phase 4 used a fresh deployment after the vulnerable environment was destroyed. This is a comparison between deployments, not proof of in-place revocation of the old credential.

The Phase 4 positive-path OIDC run proves authentication and metadata read for one known synthetic blob. It does not prove that broader permissions are absent.

Do not rerun `scripts/attack-tests.ps1`: it requires retired vulnerable-secret outputs. Do not recover the old secret from state/history, create a replacement password, or use an owner session as the workload identity.

## Execution Stages

1. Review and merge this plan through the repository PR workflow.
2. Implement a separate owner preflight and manual OIDC validation harness on a new `phase-5/feature-*` branch. Review the implementation PR before runtime execution.
3. Run owner preflight locally against known Terraform-derived targets. Capture sanitized assertions; keep values and raw errors private.
4. After implementation is merged, the owner dispatches the OIDC tests from `main`, which matches the established federation trust. Do not widen trust to make a feature-branch run succeed.
5. Review each result, capture sanitized evidence, and stop on unexpected access or inconclusive results. Remediate any findings through Terraform/code review and owner-operated deployment, then rerun affected tests.
6. Commit evidence only after reviewing actual outputs. Destroy through the owner workflow only after required Phase 5 evidence and revalidation are complete; verify cleanup separately.

This plan adds no workflow and authorizes no automatic dispatch, Terraform apply/destroy, or Azure execution by the documentation agent.

## Owner Preflight

Use the intended owner subscription context and named outputs from the current local Terraform state without printing values. Do not copy state or plans into Actions or the repository.

- Verify the workload resource group, storage account, synthetic container/blob, and negative-control canary exist at their exact expected targets.
- Verify the current workload application and service principal, and inspect both objects for password/key credentials without outputting credential records. Any unexpected credential blocks the secretless claim.
- Inspect the federated credential against the current repository's intended immutable subject, issuer, audience, and main branch restriction. Do not publish actual identifier values.
- Inspect workload role assignments, including inherited and group-derived access where applicable, at the known lab target scopes. Separate operator access from workload access. An incomplete effective-access inventory must be recorded as a limitation.
- Establish the original probe-tag state and confirm the owner can restore it before enabling any mutation probe.
- Confirm a dedicated synthetic write-probe name is absent and owner cleanup is available before enabling the storage write probe.

Preflight success proves target existence and readiness, not workload authorization. Missing targets, unavailable inspection permissions, or uncertain identity selection block the affected test.

## Validation Matrix

All results below are expected outcomes, not observed evidence.

| Test | Phase 3 relationship | Phase 5 action | Expected result |
| --- | --- | --- | --- |
| RT-01 | AT-01 replacement authentication path | Authenticate through the existing GitHub OIDC trust; confirm the session belongs to the intended workload in memory. Owner preflight checks credential absence separately. | OIDC succeeds; inspected workload objects have no password/key credentials. Old-secret replay remains NOT TESTED. |
| RT-02 | AT-02 management-plane enumeration | List resources only in the known workload resource group using the workload OIDC session. | Explicit authorization denial. An empty successful list is not proof of denial. |
| RT-03 | AT-03 management-plane excess | Attempt one reviewed benign probe-tag update on the known workload resource group. | Explicit authorization denial. Unexpected success is FAIL and requires owner restoration plus verification. |
| RT-04R | AT-04 intended data access | Read metadata for the exact existing synthetic blob with Microsoft Entra authentication. | Success. Metadata access alone does not establish a full content-download test. |
| RT-04W | Additional storage write boundary | Attempt creation of one dedicated synthetic probe blob with overwrite disabled, using Microsoft Entra authentication. | Explicit authorization denial. Unexpected success is FAIL; owner deletes only the probe and verifies its absence. |
| RT-05 | AT-05 negative-control containment | Read the exact owner-preflighted negative-control canary using the workload session. | Explicit authorization denial. |
| RT-06 | Additional broader storage boundary | Attempt container listing only within the known workload storage account using Microsoft Entra authentication. | Explicit authorization denial. This alone does not prove denial on every other container or blob. |

No deletion, key retrieval, SAS generation, role change, production data access, or arbitrary subscription enumeration is a workload probe. Owner removal of an unexpectedly created dedicated synthetic probe is the only storage cleanup contemplated here.

RT-03 and RT-04W are real mutation attempts: expected denial does not guarantee no mutation. Implement them as explicit opt-in tests, one at a time, with preflight and owner cleanup ready. Do not overwrite the baseline blob. If execution outcome is uncertain, the owner must inspect and restore the exact target before continuing.

## Harness Requirements

- Use a separate manual-only workflow with minimal GitHub permissions and a fresh isolated Azure CLI profile. Never reuse the owner's profile for workload tests.
- Keep Azure inputs in environment variables and quote arguments; do not interpolate values directly into shell source. Mask identifier/resource values before any action that may log them. Disable debug and shell tracing.
- Confirm the intended authenticated identity and subscription in memory before testing; never print IDs, claims, access tokens, credentials, raw command output, or blob contents.
- Capture native exit codes and error responses privately. Parse explicit authorization error codes through a narrow allowlist; do not treat a nonzero exit alone as success.
- Classify missing resources, authentication failure, malformed requests, transport errors, throttling, and ambiguous generic failures as INCONCLUSIVE. A generic 403 or text containing "not found" is not sufficient evidence of the intended RBAC denial.
- Run a successful known-blob positive control in the same session around the denial checks. If that control fails, do not accept the batch as validated.
- Emit only fixed test labels and PASS / FAIL / INCONCLUSIVE / NOT RUN outcomes. Unexpected success is FAIL, never a passing command execution.
- Exit nonzero for FAIL or INCONCLUSIVE; always clean up the workload CLI session/profile. Cleanup failure also blocks acceptance. Do not auto-retry mutation attempts.
- Do not upload raw logs, CLI caches, state, plans, or token-bearing artifacts.

## Acceptance and Evidence

Phase 5 remains incomplete until implemented tests have actual reviewed results, unexpected mutations have verified restoration, and any remediation has been revalidated.

The evidence record must include the reviewed code commit, execution date, public-safe workflow provenance, preflight outcome, per-test observed result, cleanup result, and limitations. Preserve Phase 3 and Phase 4 evidence unchanged.

Credential absence is a configuration inspection, not a replay test. Resource-group denial, storage-write denial, and container-list denial establish only the tested actions and targets; do not claim universal least privilege, universal trust rejection, or old-secret revocation from these results.

Return to the [attack-path index](README.md).
