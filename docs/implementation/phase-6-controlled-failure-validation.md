# Phase 6 Controlled Failure Validation

Status: Complete

Execution date: 2026-09-09

## Scope

This record documents CF-01, a controlled negative-path validation of the existing `terraform-static-validation` CI gate. The test used only a runner-temporary Terraform fixture and did not create Azure resources, authenticate to Azure, use credentials, or modify committed Terraform source.

## Baseline

- Main baseline commit: `bd387b73c646278b0a3e6af42178cdeb3e39cd9f`
- Post-merge main CI run: `34383589546` — PASS
- Baseline jobs: `terraform-static-validation`, `iac-security-scan`, and `secret-scan` — PASS

## CF-01 Controlled Failure

Controlled-failure workflow run: `34385050781`

Controlled-failure commit: `23ebafe91e0fb826ba7fdf764c359c5448c631e6`.

[Observed controlled-failure run](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/actions/runs/34385050781): overall FAILURE as intended.

Observed sequence:

1. Repository `terraform fmt -check -recursive` passed.
2. Repository `terraform init -backend=false` passed.
3. Repository `terraform validate` passed.
4. A deliberately misformatted but valid Terraform fixture was created only under `RUNNER_TEMP`.
5. The initial `terraform fmt -check -recursive` against the temporary fixture was rejected as expected.
6. `terraform fmt -recursive` remediated the temporary fixture.
7. A second `terraform fmt -check -recursive` against the temporary fixture passed.
8. The temporary fixture was removed and cleanup verification passed.
9. The bounded marker `CF-01: EXPECTED FORMATTING REJECTION VERIFIED` was emitted.
10. The controlled step intentionally exited non-zero.

Job results:

- `terraform-static-validation`: FAIL — expected, caused only by the intentional CF-01 non-zero exit after the acceptance sequence completed.
- `iac-security-scan`: PASS.
- `secret-scan`: PASS.

**CF-01 result: PASS.**

The failed workflow run is evidence of the negative-path gate behavior, not a repository defect.

## Remediation and Revalidation

The temporary failure-injection step was removed in the next commit. `.github/workflows/security-ci.yml` was restored to the exact main-branch content before documentation was added.

Remediation workflow run: `34385145419`

Remediation commit: `ac043c2d7a1727948bdd5cf17dd17a6616d835b8`.

[Observed remediation run](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/actions/runs/34385145419): overall SUCCESS.

- `terraform-static-validation`: PASS.
- `iac-security-scan`: PASS.
- `secret-scan`: PASS.

**Remediation/revalidation result: PASS.**

## Security Boundaries Preserved

- No committed malformed Terraform fixture.
- No Azure authentication or Azure resource operations.
- No OIDC `id-token` permission.
- No Azure secrets or repository variables used.
- No `terraform plan`, `apply`, or `destroy`.
- No changes to `terraform/*.tf`.
- No changes to `.trivyignore.yaml`; the reviewed `AZU-0012` exception remains unchanged.
- No changes to historical Phase 3 evidence, Phase 4/5 workflows, screenshots, or scripts.
- No changes to Phase 4, Phase 5, or Phase 7 evidence.
- No sensitive identifiers, tokens, Terraform state/plans, CLI caches, or raw sensitive logs are included in this record.

## Bounded claim

CF-01 demonstrates only that the tested Phase 6 Terraform formatting gate rejected the deliberately misformatted temporary Terraform fixture and accepted it after formatting remediation. It does not prove that all CI failures or Terraform security defects will be detected, Azure authorization correctness, OIDC runtime correctness, universal least privilege, universal secret detection, or production suitability.

## Final repository condition

The controlled-failure workflow mutation is retained only in commit history for auditability. The normal `.github/workflows/security-ci.yml` content matches main exactly; the net diff is documentation only. No controlled fixture, permanent negative-path step, conditional test code, or test environment variable remains. Repository Terraform files are unchanged. The fixture existed only beneath RUNNER_TEMP and was removed before the intentional failure and runner completion. The Azure validation environment remains destroyed.

Repository ruleset hardening, GitHub Actions default-permission verification, historical Phase 4/5 OIDC workflow retirement, stale Phase 4 repository-variable cleanup, final Phase 6 evidence consolidation, and project retrospective remain separate pending work.
