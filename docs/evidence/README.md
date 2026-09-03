# Evidence Index

## Evidence Principles

Retain verified outputs only. Do not fabricate results. Public evidence must be sanitized and must not contain secrets, IDs, tokens, Terraform state, plans, or unnecessary environment details.

## Phase 2

[Phase 2 validation](phase-2-validation.md) records the vulnerable infrastructure deployment and owner-context validation. Sanitized supporting images are in [screenshots/phase-2](screenshots/phase-2/).

## Phase 3

[Phase 3 validation](phase-3.md) records controlled credential-compromise validation. Sanitized images are in [screenshots/phase-3](screenshots/phase-3/), including AT-01 through AT-05 and `phase-3-all-tests-success.png`.

Phase 3 evidence is the immutable vulnerable-state baseline except for factual or redaction corrections.

## Future Evidence

Phase 4 evidence will document remediation deployment, GitHub OIDC, federated identity, and least-privilege work when it occurs. Phase 5 evidence will record post-remediation re-attack results. Neither phase has started, and no future results are created in advance.

See the [evidence plan](evidence-plan.md) and return to the [documentation guide](../README.md).
