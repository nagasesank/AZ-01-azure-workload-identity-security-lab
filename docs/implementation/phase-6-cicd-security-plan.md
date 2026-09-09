# Phase 6 CI/CD Security Controls Plan

Status: Security control plan prepared; implementation and validation pending.

Planning baseline: 2026-09-09, main commit `a11ec7da99e721af6d3317b0e988eccc0543e9b8`.

## Objective and boundaries

Phase 6 is repository-first CI/CD security hardening with no Azure runtime dependency unless a later explicitly approved validation requires one. This is a documentation-only plan. It adds no workflow, dependency automation, ruleset, or security setting and performs no runtime execution.

Phase 3 is complete and remains the immutable vulnerable baseline. Phase 4 and Phase 5 are complete, Phase 5 evidence is reviewed, and Phase 7 teardown/cleanup evidence is complete. The later AZ-01 Azure validation deployment is destroyed. Existing Phase 4/5 OIDC workflows are historical runtime-validation artifacts; their source and the Phase 3/4/5/7 evidence remain unchanged.

The owner-provided baseline is that main is presently unprotected and no repository ruleset exists. Target settings below are proposals, not claims of enforcement. Phase 6 remains incomplete until implementation, observed validation, and owner verification satisfy the acceptance criteria.

## Control matrix

All CI-01 through CI-11 controls below are planned; none is asserted to be implemented by this PR.

| Control | Planned requirement | Acceptance evidence |
| --- | --- | --- |
| CI-01 — Safe CI trigger and permissions | Future security CI runs on `pull_request` and `push` to main; never use `pull_request_target`. Default permissions are `contents: read` only, with no `id-token` permission, Azure secrets, or repository Azure identifiers. Add job timeouts and concurrency/`cancel-in-progress` controls. | Reviewed workflow shows the exact triggers, minimal permissions, timeout and concurrency settings; observed runs require no Azure context. |
| CI-02 — Immutable action references | Pin every external action in the future Phase 6 workflow to a full 40-character commit SHA; comments may identify its human-readable release/tag. Do not rewrite historical Phase 4/5 workflow provenance. Retire those workflows by disabling them after evidence preservation. | Review verifies every external action reference and records owner confirmation of historical workflow disablement separately. |
| CI-03 — Terraform static validation | Run `terraform fmt -check -recursive`, `terraform init -backend=false`, and `terraform validate` against the Terraform configuration. No `terraform plan`, `apply`, `destroy`, or Azure authentication. | Normal static CI passes without state/backend access or Azure credentials. These commands are for later implementation, not execution in this planning change. |
| CI-04 — IaC security scanning | Scan Terraform configuration for security/misconfiguration findings. Review the scanner baseline before deciding dispositions; do not blindly suppress findings. HIGH/CRITICAL gating must be fail-closed after findings are reviewed. Each suppression requires a narrow documented technical rationale. Never weaken Terraform permissions or controls to make the scanner pass. | Reviewed finding dispositions and narrow exceptions, followed by an enforced gate. Scanner execution errors or missing results must fail the gate rather than appear as a clean scan. |
| CI-05 — Secret scanning | CI scanning must not print discovered secret values. Verify/enable repository-native secret scanning and push protection where available. Preserve existing `.gitignore` credential/state exclusions. Never commit a synthetic real-looking credential for testing. | Redacted scan outcomes and owner verification of available repository controls. Record unavailable features as limitations rather than claiming enablement. |
| CI-06 — Dependency maintenance | A future `.github/dependabot.yml` covers `github-actions` and `terraform` with a conservative weekly cadence. Updates remain subject to normal PR review and CI. | Reviewed configuration covers both ecosystems and their repository directories; dependency PRs use the normal review/check path. |
| CI-07 — Main branch ruleset | Current baseline: main is unprotected and no repository ruleset exists. Require a PR before merge, the Phase 6 CI status check, and conversation resolution; block force pushes and branch deletion. Do not require another-person approval for this solo-maintained repository or linear history for its merge-commit workflow. Configure the required check only after it exists. | Owner verifies the applied ruleset and exact required check. Do not claim these settings are enabled before that verification. |
| CI-08 — GitHub Actions repository permissions | Owner verifies/hardens default workflow token permissions to read-only. Do not allow Actions to create or approve PRs unless a demonstrated future requirement exists. | Sanitized owner verification of both settings; no claim of current enablement from this plan. |
| CI-09 — Historical OIDC retirement/config cleanup | Preserve Phase 4/5 workflow source unchanged. After Phase 6 implementation review and evidence preservation, the owner disables those workflows instead of deleting them. Verify whether exact stale Phase 4 Azure repository variable names still exist without reading, enumerating, or exposing their values. Remove only exact stale variables after owner review. Phase 5 repository secrets were already removed during Phase 7. | Owner records workflow disablement and name-only presence/absence and cleanup outcomes, or explicit not-applicable findings. No Azure config values are recorded. |
| CI-10 — Controlled failure validation | Implement in a later PR. Create a temporary intentionally noncompliant fixture only inside the GitHub runner workspace; commit neither a fake secret nor a vulnerable cloud resource. Prove at least one Phase 6 gate detects/rejects it, then remove it and revalidate the normal repository. The final repository tree contains no intentionally broken fixture. | Sanitized controlled failure evidence, fixture cleanup confirmation, and successful remediation/revalidation evidence. |
| CI-11 — Evidence/acceptance | Require the reviewed implementation PR, successful normal CI, controlled negative-path failure, successful remediation/revalidation, owner-verified ruleset and Actions permissions, disabled historical OIDC workflows, and exact stale Azure config cleanup where applicable. Commit sanitized evidence only after actual observations. No Azure deployment unless separately authorized. | Evidence maps observed outcomes and owner assertions to each control; incomplete checks remain pending rather than being reported as complete. |

## Implementation and validation design

Use a separate implementation PR for the new static workflow and dependency automation. Select and review scanner versions, baseline findings, and the stable CI check name there. IaC scanning must fail closed on reviewed HIGH/CRITICAL findings; exceptions must identify the specific finding, technical rationale, and bounded scope. Baseline review is not acceptance of unresolved risks by default.

For CI-10, prefer a harmless formatting violation in a temporary runner-only copy of configuration to exercise the formatting gate. The reviewed negative-path design must produce an observable gate rejection, clean up even when the gate fails, and then demonstrate a clean normal repository run. It must not authenticate to Azure, provision anything, or print credentials. One rejected fixture demonstrates only that tested gate and failure mode, not every control's effectiveness.

For CI-09, derive the exact candidate variable names from the preserved Phase 4 workflow references during later owner review. Use metadata-only/name-only checks without fetching or printing values; if a method cannot guarantee that, stop and select a method that can. Any removal is limited to reviewed exact stale names. Do not broaden cleanup to unrelated repository configuration.

## Intended sequence

1. Merge the Phase 6 planning PR through the owner review process; this planning task does not merge it.
2. Create the separate `phase-6/feature-cicd-security-controls` branch.
3. Implement the new static CI workflow and dependency automation.
4. Review the implementation PR before executing controlled failure validation.
5. Run normal CI.
6. Run the safe controlled negative-path test.
7. Remediate/revalidate.
8. Configure/verify the main ruleset after the required CI check exists.
9. Harden/verify repository Actions permissions.
10. Disable the historical Phase 4/5 OIDC workflows while preserving their source.
11. Verify/remove exact stale Phase 4 Azure variables if present, after owner review.
12. Capture sanitized Phase 6 evidence.
13. Submit an evidence PR and complete final review.
14. Conduct the final project retrospective only after Phase 6 is complete.

## Evidence and completion criteria

The implementation and evidence reviews must establish all of the following:

- A reviewed implementation PR and successful normal CI run.
- A controlled negative-path CI failure and successful remediation/revalidation run, with no broken fixture left in the final repository tree.
- Owner-verified main ruleset and GitHub Actions default permissions.
- Owner-confirmed disablement of historical OIDC workflows.
- Verified exact stale Azure config cleanup where applicable, while retaining the Phase 7 fact that Phase 5 repository secrets were removed.
- Sanitized evidence committed after observations, with limitations and unavailable controls recorded explicitly.

Do not publish Azure subscription, tenant, client/application, object/principal identifiers, OIDC subjects, tokens, secret values, Terraform state/plans, CLI caches, or raw sensitive scanner output. Record discovered-secret findings without the values. No evidence is fabricated in this planning PR.

Static CI success does not establish Azure runtime authorization, universal least privilege, universal cleanup, or old-secret replay failure. Phase 6 controls do not change the bounded conclusions of historical runtime evidence. No Azure deployment is required unless separately authorized.

## Related documentation

- [Implementation index](README.md)
- [GitHub automation](../../.github/README.md)
- [Phase 5 runtime validation](../evidence/phase-5-runtime-validation.md)
- [Phase 7 teardown validation](../evidence/phase-7-teardown-validation.md)
