# Phase 6 Repository Hardening

Status: COMPLETE.

Verification and closeout review date: 2026-09-09. This record distinguishes observed GitHub settings from repository-file changes proposed and reviewed through PR #31.

## Repository baseline

Current main at the start of closeout was `2c3342ee5c2f5c110452cac9eef58b0ea164d46d`, the expected merge of PR #30. It remained the file-change baseline for PR #31.

[Post-merge Phase 6 Security CI run 34385755900](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/actions/runs/34385755900) completed successfully on that commit. The observed successful check contexts were exactly `terraform-static-validation`, `iac-security-scan`, and `secret-scan`, supplied by GitHub Actions (integration 15368). These names were used for protection, rather than guessed workflow-prefixed strings.

[CF-01 validation](phase-6-controlled-failure-validation.md) is complete, including the intended formatting rejection and successful remediation/revalidation. Static CI does not require a live Azure environment.

## Dependency PR disposition

| PR | Inspected scope | Before | Verified after | Rationale |
| --- | --- | --- | --- | --- |
| [#28](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/pull/28) | Only azure/login v2 to v3 in historical Phase 4/5 OIDC workflow files | Open, unmerged | Closed, unmerged | Those workflows are retired; preserve their validated dependency provenance. A closure comment records this decision. |
| [#29](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/pull/29) | AzureRM 4.81.0 to 5.4.0, provider constraint and lockfile | Open, unmerged | Closed, unmerged | Retain the AzureRM 4.x validated/destroyed lab baseline. Static initialization/validation alone cannot establish major-version migration or apply compatibility. A closure comment records this decision. |

Neither PR was merged, and no dependency version or provider lockfile was changed during closeout.

## Main ruleset

Before: repository ruleset listing was empty; main reported `protected: false`.

[Ruleset 22668558 — AZ-01 main security controls](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/rules/22668558) was created with active enforcement for `refs/heads/main`, then fetched again. The effective branch-rules endpoint also confirmed these rules apply:

- Require a pull request; required approving reviews: 0, with no code-owner or last-push approval requirement.
- Require conversation resolution.
- Require all three verified GitHub Actions check contexts: `terraform-static-validation`, `iac-security-scan`, and `secret-scan`.
- Require the PR branch to be up to date for the status-check policy.
- Block non-fast-forward updates and branch deletion.
- No bypass actors, deployment requirement, signed-commit requirement, or linear-history rule was added. Merge commits remain allowed.

GitHub also returned its default `require_extra_approval_for_unattributed_changes: true`; no mandatory ordinary second-person review was configured. The active ruleset and effective branch rules were verified through read-only API calls, not by attempting a destructive push or deletion. No repository-plan/API limitation prevented the intended rules.

## GitHub Actions permissions

| Setting | Before | Final verification | Action |
| --- | --- | --- | --- |
| Default workflow permission | `read` | `read` | Already compliant; no mutation |
| Workflows may approve pull requests | `can_approve_pull_request_reviews: false` | `false` | Already compliant; no mutation |

The existing security workflow's explicit `permissions: contents: read` remains unchanged. No token or organization-level setting was changed. Repository defaults and this observed approval setting are the scope of the assertion; they are not a universal statement about every app's permissions.

## Historical OIDC workflow retirement

Source inspection confirmed both workflows were manual Azure/OIDC runtime validation paths using azure/login and OIDC token permission. Their Azure input references were inspected by name only.

| Workflow | File | ID | Before | Verified after |
| --- | --- | --- | --- | --- |
| Phase 4 OIDC Validation | `.github/workflows/phase-4-oidc-validation.yml` | 353833192 | active | disabled_manually |
| Phase 5 OIDC Re-attack Validation | `.github/workflows/phase-5-oidc-validation.yml` | 353968573 | active | disabled_manually |

Each was disabled through its workflow administration endpoint and immediately fetched to verify state. They were NOT executed during retirement. Their YAML source remains unchanged as historical provenance. Phase 6 Security CI and Dependabot Updates remain active.

## Repository variable/secret cleanup

Name-only inspection identified four repository Actions variables. Current-main reference searches showed they belonged to the retired Phase 4 workflow; corresponding secret-name references occur in the retired Phase 5 workflow. No active automation required them.

| Repository variable name | Before | Verified after |
| --- | --- | --- |
| `AZ01_STORAGE_ACCOUNT` | Present; historical Phase 4 input | Removed; name absent |
| `AZURE_CLIENT_ID` | Present; historical Phase 4 input | Removed; name absent |
| `AZURE_SUBSCRIPTION_ID` | Present; historical Phase 4 input | Removed; name absent |
| `AZURE_TENANT_ID` | Present; historical Phase 4 input | Removed; name absent |

Each deletion was followed by a name-only absence check. No values were printed, documented, or saved as evidence. An initial deletion attempt was blocked before execution by the automatic approval review service's usage limit; the renewed request completed the deletions and verification. No blocker remains.

Repository secret-name listings were empty before and after this cleanup. No secret deletion was necessary; this is consistent with Phase 7 removal of the Phase 5 repository secrets. This checks repository-level names only, not every possible organization/environment configuration.

## Dependabot closeout policy

The reviewed [Dependabot configuration](../../.github/dependabot.yml) preserves weekly GitHub Actions and Terraform updates and the five-open-PR limit. It ignores semver-major updates for GitHub Actions dependencies and the three current Terraform providers: `hashicorp/azurerm`, `hashicorp/azuread`, and `hashicorp/random`. Patch/minor updates are not blocked. No provider source, lockfile, or dependency major version is updated.

Future major migrations require separate explicit compatibility review. The policy does not mean dependencies are permanently safe or that maintenance can stop.

## Security boundaries

No Azure authentication or Azure resource creation/modification occurred. No Terraform plan/apply/destroy, state/plan access, or Azure CLI cache access occurred. No client secret was recreated.

No Terraform source, executable script, historical Phase 3/4/5/7 evidence, historical screenshot, or workflow source was changed. `.trivyignore.yaml` and the reviewed time-bounded AZU-0012 lab exception remain unchanged. No raw sensitive logs, tokens, secret values, or Azure identifier values are documented.

## Validation and final Phase 6 status

PR #31 was reviewed for exact file scope, Dependabot major-only policy, relative documentation links, sensitive-value patterns, `git diff --check`, and unchanged workflow/Terraform/evidence/lockfile content. The branch previously demonstrated all three static CI checks passing, and the protected-main ruleset requires the current PR head to pass those same checks before merge.

Static CI, CF-01, repository protection, Actions defaults, historical OIDC workflow retirement, stale-variable cleanup, dependency-policy hardening, evidence review, and closeout review are complete. Phase 6 is therefore COMPLETE. The Azure validation environment remains destroyed, and no merge path may bypass the required checks.

See the [project retrospective](project-retrospective.md) and [implementation index](README.md).
