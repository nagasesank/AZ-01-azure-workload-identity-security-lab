# Phase 3 Attack Validation Evidence

Phase 3 evidence is captured only after an owner intentionally runs one approved test at a time. No Phase 3 attack test has been executed for this record.

## Expected Screenshots

- `AT-01-exposed-credential-authentication.png`
- `AT-02-workload-rg-enumeration.png`
- `AT-03-management-plane-tag-mutation.png`
- `AT-04-synthetic-blob-access.png`
- `AT-05-negative-control-denied.png`

## Required Redactions

Before publication, redact subscription IDs, tenant IDs, client or application IDs, object or principal IDs, access or refresh tokens, client secrets, and unnecessary local or environment identifiers. Do not include Terraform state, blob contents, or raw Azure authorization errors in screenshots.

## Test Scope

AT-01 validates the intentionally vulnerable credential in an isolated Azure CLI profile. AT-02 through AT-04 are limited to the workload resource-group boundary and known synthetic data. AT-05 is limited to the known project-owned negative-control canary and is expected to be denied. Phase 4 remediation is not covered by this evidence record.
