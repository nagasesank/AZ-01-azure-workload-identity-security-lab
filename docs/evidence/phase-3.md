# Phase 3 Attack Validation Evidence

Phase 3 evidence was captured after an owner intentionally ran approved tests one at a time against the controlled lab. Terraform resource cleanup and state handling were owner-operated after evidence capture; the lab was intentionally destroyed for cost control.

## Verified Results

- AT-01 passed: the intentionally exposed vulnerable service-principal credential authenticated successfully.
- AT-02 passed: workload resource-group enumeration succeeded within the lab boundary.
- AT-03 passed: the harmless workload resource-group probe-tag mutation succeeded and the original tag state was restored and verified.
- AT-04 passed: access to the known synthetic blob succeeded.
- AT-05 passed: access to the project-owned negative-control canary was denied as expected, verifying containment outside the compromised identity's authorization boundary.

## Screenshot Inventory

- `AT-01-exposed-credential-authentication.png`
- `AT-02-workload-rg-enumeration.png`
- `AT-03-management-plane-tag-mutation.png`
- `AT-04-synthetic-blob-access.png`
- `AT-05-negative-control-denied.png`
- `phase-3-all-tests-success.png`

Only screenshots that meet the redaction requirements below are retained in the repository.

## Required Redactions

Before publication, redact subscription IDs, tenant IDs, client or application IDs, object or principal IDs, access or refresh tokens, client secrets, and unnecessary local or environment identifiers. Do not include Terraform state, blob contents, or raw Azure authorization errors in screenshots.

## Test Scope

AT-01 validates the intentionally vulnerable credential in an isolated Azure CLI profile. AT-02 through AT-04 are limited to the workload resource-group boundary and known synthetic data. AT-05 is limited to the known project-owned negative-control canary and is expected to be denied. The lab was destroyed after this validation to control cost. Phase 4 remediation is not covered by this evidence record.
