# AZ-01 Project Retrospective

Status: Retrospective prepared; final closeout review pending.

## Project objective

AZ-01 is a synthetic security lab exploring how a copied workload credential and excessive authorization combine, then testing secretless authentication and bounded authorization after remediation. It makes no production-system claim.

## Vulnerable baseline

[Phase 3 evidence](../evidence/phase-3.md) remains the immutable historical vulnerable baseline. The controlled identity authenticated, enumerated the workload resource group, performed a benign tag mutation with verified restoration, and accessed the known synthetic blob. The vulnerable environment was later destroyed.

## Attack-path findings

Credential compromise exposed actions already authorized to that identity within the tested workload boundary. Successful authentication did not itself explain or limit subsequent authorization. The test did not enumerate arbitrary subscription resources or access production data.

## OIDC remediation

Phase 4 used a later secretless deployment with GitHub OIDC federation and reduced authorization scope. [Runtime evidence](../evidence/phase-4-runtime-validation.md) records successful OIDC authentication and metadata access to the intended synthetic blob. This was a different deployment window, not proof of in-place revocation or replay failure of the retired Phase 3 credential.

## Least-privilege validation

[Phase 5](../evidence/phase-5-runtime-validation.md) validated intended blob metadata access alongside explicit denials for the tested workload resource-group enumeration, benign tag mutation, dedicated synthetic blob creation, and account-level container listing. RT-03 and RT-04W ran separately. Claims remain limited to those actions and known targets; arbitrary content downloads or universal storage-write denial were not demonstrated.

## Negative-control validation

The known project-owned canary provided a concrete containment check in both the vulnerable and later validation windows. Denial against that exact canary does not establish denial against every other resource.

## Teardown

[Phase 7 verification](../evidence/phase-7-teardown-validation.md) records successful owner-operated teardown, empty Terraform state, and absence of the exact known resource groups and workload identity objects. Phase 5 repository secrets were removed. The Azure validation environment remains destroyed; no client secret or cloud resource was recreated during closeout.

## CI/CD hardening

Repository-static CI covers formatting/schema validation, IaC scanning, and current-content secret scanning. [CF-01](phase-6-controlled-failure-validation.md) demonstrated rejection and formatting remediation of a runner-only fixture; normal workflow behavior was restored with zero net workflow change.

[Repository hardening](phase-6-repository-hardening.md) adds verified main ruleset enforcement, confirms read-only Actions defaults, retires historical OIDC workflows through disablement, and removes unused repository variable names. Phase 6 repository controls are the final hardening layer, not a substitute for runtime evidence.

## Key engineering decisions

- Preserve historical evidence and workflow source; disable retired execution paths instead of rewriting provenance.
- Separate authentication, authorization, preflight configuration inspection, and cleanup assertions.
- Use explicit denial classification and same-session positive controls; treat ambiguous failures conservatively.
- Keep mutation probes separate, bounded, and reversible.
- Require static checks through PRs without imposing impossible routine self-review.
- Retain the validated provider major-version baseline while preserving weekly patch/minor dependency visibility.

## What worked

Known targets, synthetic data, negative controls, explicit result labels, and separate deployment-window records made claims reviewable. The controlled CI test proved an actual rejected path and successful remediation, rather than relying solely on a green normal run. Teardown and stale-configuration cleanup reduced accidental reuse of retired runtime paths.

## What deliberately remained out of scope

Production workloads, arbitrary subscription enumeration, universal permission proofs, retired-secret replay testing, and major-provider migration/apply testing were not performed. Static CI does not recreate the destroyed environment. No new screenshot or fabricated runtime evidence was needed for administration verification.

## Security limitations

Blob metadata access is narrower than arbitrary content access. Tested denials do not prove universal least privilege or authorization correctness. Current-content secret scanning does not establish clean full Git history. Static IaC checks do not cover cloud behavior outside the scanned configuration.

The AZU-0012 exception is specific to the synthetic lab, remains unchanged, and is time-bounded through 2026-12-31. It requires re-review before any future deployment or expiration. Rule enforcement was checked through effective configuration, not destructive bypass attempts. Configuration can change after this dated verification, so future reuse requires review.

## Lessons learned

A successful command and a secure outcome are different things: unexpected access is failure, while an intentionally rejected formatting fixture can prove enforcement. Positive controls and precise failure classification prevent false confidence. Evidence must distinguish historical experiments from current operational state, and dependency modernization must not silently change a validated baseline.

## Final project state

The Azure validation environment is destroyed. The client secret was not recreated. This remains a synthetic security lab with no production suitability claim. Phase 3/4/5 evidence remains historical; Phase 7 preserves teardown verification.

Phase 6 repository controls are implemented and verified, and this retrospective captures the completed engineering work. Final evidence/closeout review remains pending in the open PR; the task does not merge or archive the repository. Future maintenance and any redeployment require deliberate review.

Return to the [implementation index](README.md).
