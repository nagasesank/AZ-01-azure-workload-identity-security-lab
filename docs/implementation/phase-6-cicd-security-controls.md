# Phase 6 CI/CD Security Controls Implementation

Status: Implementation corrected after initial CI; revalidation pending.

Baseline: merged Phase 6 plan at `b0fe869c8516894f8c066d7dec36b768ebe77b7e`.

## Objective

Implement repository-static CI without an Azure runtime dependency. Phase 6 remains in progress: code preparation and CI execution are separate from owner-verified repository controls. The AZ-01 Azure validation environment remains destroyed.

## Implemented repository controls

[security-ci.yml](../../.github/workflows/security-ci.yml) defines workflow **Phase 6 Security CI** with these stable job IDs and display names:

| Job | Gate |
| --- | --- |
| `terraform-static-validation` | Terraform formatting, backend-free initialization, and configuration validation |
| `iac-security-scan` | Trivy Terraform misconfiguration scan; unexcepted HIGH/CRITICAL findings fail |
| `secret-scan` | Trivy current-repository content scan; secret findings at any severity fail |

Use these exact job names when verifying required status checks later; the workflow context is `Phase 6 Security CI / <job-name>`. The owner must select the actual observed checks after successful runs, without casually renaming them. All jobs have 15-minute timeouts and run on GitHub-hosted Ubuntu 24.04.

## Workflow triggers

The only triggers are `pull_request` and `push` to main. There is no privileged PR-target trigger, workflow chaining, schedule, or manual dispatch. Concurrency groups include workflow and ref, with redundant in-progress runs cancelled.

## Explicit GitHub permissions

Top-level permissions are exactly `contents: read`; unspecified permissions are not granted. No write permissions, OIDC token permission, Azure secrets, Azure repository variables, or ARM credentials are requested. Checkout uses `persist-credentials: false`. No SARIF upload, PR comments, or scanner report artifacts are configured.

## Action pinning policy

Every external action reference in the new workflow uses a full 40-character commit SHA with a stable release comment. The pins were resolved from official upstream tag refs, dereferencing the annotated Trivy action tag to its commit:

| Action | Release | Commit |
| --- | --- | --- |
| [actions/checkout](https://github.com/actions/checkout/releases/tag/v7.0.1) | v7.0.1 | `3d3c42e5aac5ba805825da76410c181273ba90b1` |
| [hashicorp/setup-terraform](https://github.com/hashicorp/setup-terraform/releases/tag/v4.0.1) | v4.0.1 | `dfe3c3f87815947d99a8997f908cb6525fc44e9e` |
| [aquasecurity/trivy-action](https://github.com/aquasecurity/trivy-action/releases/tag/v0.36.0) | v0.36.0 | `ed142fd0673e97e23eac54620cfb913e5ce36c25` |

Terraform CLI is explicitly set to 1.14.8 and Trivy CLI to v0.70.0. The reviewed Trivy composite action pins its setup action; action caching is disabled. Action pinning fixes action source but does not make hosted runners, provider downloads, or scanner check updates immutable. Review dependency updates through ordinary PRs and CI.

## Terraform static commands

The following execute from `terraform/`, in order, with failures propagated:

```text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

No plan, apply, destroy, state retrieval, Terraform output retrieval, backend initialization, or Azure authentication is performed. Initialization downloads providers; validation checks configuration and provider schemas without a deployment. The setup wrapper is disabled to avoid unnecessary captured command outputs.

## IaC scanning policy

Trivy configuration scanning is scoped to `terraform/`, using misconfiguration rules and HIGH/CRITICAL severity gating with exit code 1. Scanner execution errors fail the job; a missing or malformed JSON report also fails. There is no continue-on-error path or automatic remediation.

The first observed PR run, GitHub Actions run `34382589099`, reported exactly one CRITICAL IaC finding: `AZU-0012`. The finding corresponds to the storage account design allowing public-network reachability rather than defining a default-deny storage firewall. This was reviewed rather than silently suppressed.

AZ-01 intentionally needs the synthetic storage endpoint reachable from owner workstations and GitHub-hosted runners during bounded OIDC validation. Compensating controls in the Terraform design include disabled shared-key authentication, OAuth as the default authentication mode, TLS 1.2 minimum, a private container, and synthetic data only. Because the current Azure environment is destroyed and this reachability is a deliberate lab requirement rather than production guidance, `AZU-0012` is recorded as one explicit time-bounded exception in [`.trivyignore.yaml`](../../.trivyignore.yaml), expiring 2026-12-31. The exception must be re-reviewed before any future Azure deployment or before expiration. No Terraform `.tf` file is changed to make the scanner pass, and no wildcard or blanket suppression is used.

All other HIGH/CRITICAL findings remain fail-closed. Future exceptions require a similarly narrow reviewed technical rationale and should not be added merely to make CI green.

## Secret scanning policy

Trivy is used for both IaC and secret detection, avoiding another action integration and PR-API permissions. The filesystem secret scan covers the checked-out repository content using all severities. It does not traverse all historical Git revisions; passing it is not a clean-history claim. Scanner coverage and file-type limitations still apply. See [Trivy secret scanning documentation](https://trivy.dev/docs/latest/scanner/secret/).

In the first observed PR run, the Trivy secret-scan action itself completed successfully with `exit-code: 1`, but the following report-validation step failed because it required a specific `ArtifactType` value. That check was stricter than necessary for a valid Trivy schema-v2 filesystem result. The validator now requires valid JSON schema version 2 and a list-shaped `Results` field when present; missing `Results` is accepted as an empty result set. The Trivy action remains the primary fail-closed secret-detection gate, while the post-processing step only emits safe finding metadata and rejects malformed reports.

Both scanners write JSON only to runner temporary storage. Reporting steps emit counts and allowlisted-format rule IDs/severities, never matched values, source snippets, paths, or full reports. Temporary reports are deleted by the reporting step, including on scan failure. Cancellation relies on disposal of the ephemeral hosted runner. Raw reports/logs are not committed or uploaded as artifacts.

No synthetic credentials, broad allowlists, or historical evidence rewrites are introduced. If a finding requires changing historical evidence, stop and report only necessary metadata for owner review. Repository-native secret scanning/push protection availability and enablement remain owner-verification work; current credential/state exclusions remain unchanged.

## Dependabot configuration

[dependabot.yml](../../.github/dependabot.yml) defines exactly two ecosystems: `github-actions` at `/` and `terraform` at `/terraform`. Each runs weekly with an open-PR limit of five. There is no automatic merge or review/CI bypass. Configuration was checked against the [GitHub Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference). Review any future suggested historical-workflow update against the preservation requirement before accepting it.

## Why Azure/OIDC is absent

These checks inspect repository content and configuration, so no cloud identity or deployment is needed. The historical Azure validation environment is destroyed; Phase 5 repository secrets were removed during Phase 7. No secret restoration, Azure session, or OIDC trust change is needed for this implementation.

## Historical Phase 4/5 workflow preservation

The two historical OIDC workflow files and all Phase 3/4/5/7 evidence remain unchanged. No historical harness is run and no workflow is disabled by this PR.

## Pending CI-07 ruleset

The owner-provided baseline remains main unprotected/no repository ruleset. After stable successful CI checks exist, the owner will configure/verify:

- PR required before merge, required Phase 6 security checks, and conversation resolution.
- Block force pushes and branch deletion.
- No mandatory second-person approval for this solo-maintained repository.
- No linear-history requirement because merge commits are used.

These settings are not claimed enabled.

## Pending CI-08 repository Actions permissions

Owner verification/hardening must set default GITHUB_TOKEN permissions to read-only and prevent Actions from creating/approving PRs unless a later demonstrated requirement justifies it. Workflow-local permissions do not prove repository defaults are hardened. No settings were changed.

## Pending CI-09 retirement/config cleanup

After implementation review and evidence preservation, the owner will disable the historical Phase 4/5 workflows without deleting or rewriting their source. Verify exact stale Phase 4 Azure variable names without exposing values; remove only reviewed stale names if present. No variable/secret cleanup occurs here. Phase 5 secrets were already removed during Phase 7.

## Planned CI-10 controlled failure validation

In a later reviewed change, create a harmless formatting violation only in a temporary configuration copy under RUNNER_TEMP. Run the exact `terraform fmt -check -recursive` logic there and require a nonzero exit. Remove the fixture, then rerun normal repository formatting, backend-free initialization, and validation successfully. Record the observed failure and remediation/revalidation separately.

No intentionally bad fixture is committed or executed in this PR; no fake secret or vulnerable cloud resource is used. The final repository tree must contain no broken fixture. One negative-path result proves only the tested gate and failure mode.

## Validation and evidence status

Local Terraform 1.14.8 formatting passed. Backend-free initialization and validation passed in an isolated copy; validation returned zero errors and zero warnings. No Azure/runtime operation was performed. YAML structure, minimal permissions, trigger/job/pin constraints, Dependabot fields, relative links, and changed-file scope were checked before the original implementation commit.

Initial GitHub Actions run `34382589099` produced the following bounded observations:

| Job | Observed result |
| --- | --- |
| `terraform-static-validation` | PASS |
| `iac-security-scan` | FAIL — one reviewed `AZU-0012` CRITICAL finding |
| `secret-scan` | FAIL — Trivy scan step succeeded; report validator rejected the report shape |

The workflow correction records the reviewed `AZU-0012` exception and relaxes only the over-strict report-shape assumptions. A new PR run is required before any CI-success claim is made.

Phase 6 completion still requires successful normal CI observation, controlled negative-path failure, remediation/revalidation, owner-verified ruleset and Actions settings, historical workflow disablement, exact stale variable cleanup where applicable, and sanitized evidence based on actual observations. Final retrospective remains pending.

## Security limitations

Static CI does not establish Azure runtime authorization, universal least privilege, old-secret replay failure, universal Azure cleanup, OIDC runtime authentication, or cloud resource security outside the scanned configuration. The `AZU-0012` exception is a documented lab-specific risk acceptance, not a statement that public storage networking is generally secure. Provider/scanner availability failures are not successful validation. No screenshots or CI evidence are fabricated.

See the [approved Phase 6 plan](phase-6-cicd-security-plan.md) and [implementation index](README.md).
