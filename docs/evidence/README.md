# Evidence Index

## Evidence Principles

Retain verified outputs only. Do not fabricate results. Public evidence must be sanitized and must not contain secrets, IDs, tokens, Terraform state, plans, or unnecessary environment details.

## Phase 2

[Phase 2 validation](phase-2-validation.md) records the vulnerable infrastructure deployment and owner-context validation. Sanitized supporting images are in [screenshots/phase-2](screenshots/phase-2/).

## Phase 3

[Phase 3 validation](phase-3.md) records controlled credential-compromise validation. Sanitized images are in [screenshots/phase-3](screenshots/phase-3/), including AT-01 through AT-05 and `phase-3-all-tests-success.png`.

Phase 3 evidence is the immutable vulnerable-state baseline except for factual or redaction corrections.

## Phase 4

[Phase 4 runtime validation](phase-4-runtime-validation.md) records the successful manual GitHub OIDC authentication and metadata-only read validation against the known synthetic blob. Raw workflow logs are not copied because expanded action inputs can expose identifiers.

## Future Evidence

Phase 5 evidence will record post-remediation authorization and re-attack results. Those tests have not been run, and no future results are created in advance.

See the [evidence plan](evidence-plan.md) and return to the [documentation guide](../README.md).
