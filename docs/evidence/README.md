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

The inspected [Phase 4 screenshots](screenshots/phase-4/) support the successful authentication, intended read, and cleanup results. They do not establish Phase 5 authorization-denial results.

## Phase 5

Post-remediation runtime validation completed on 2026-09-09. [Phase 5 runtime validation](phase-5-runtime-validation.md) records owner preflight and three bounded reviewed dispatches, including separate RT-03 and RT-04W probes and successful session cleanup.

The owner will manually add the five sanitized images to [screenshots/phase-5](screenshots/phase-5/). Evidence review and infrastructure teardown remain pending; the current validation environment is active.

See the [evidence plan](evidence-plan.md) and return to the [documentation guide](../README.md).
