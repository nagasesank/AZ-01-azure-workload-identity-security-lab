# Phase 1 Controlled Attack Plan

## Scope and Safety

This is a future, controlled test plan, not an attack execution record. The assumed compromise is possession of the intentionally created lab credential. Authentication proves the service principal identity; authorization determines which management-plane and data-plane actions it can perform. Future workload tests are limited to `rg-az01-workload-lab` and synthetic data. AT-05 uses only a known benign canary in project-owned `rg-az01-negative-control`; it does not target arbitrary subscription resources.

| Test | Security Question | Vulnerable Expected Result | Remediated Expected Result |
| ---- | ----------------- | -------------------------- | -------------------------- |
| AT-01 | Can the intentionally exposed lab service-principal credential authenticate? | `ALLOWED` | `DENIED` after client secret removal. |
| AT-02 | Can the identity enumerate resources in the dedicated AZ-01 resource group? | `ALLOWED` | Only intended scope/actions allowed. |
| AT-03 | Can the identity perform an intentionally excessive management-plane action on an AZ-01 lab resource? | `ALLOWED` | `DENIED` if outside required workload permissions. |
| AT-04 | Can the identity access synthetic data when deliberately granted data-plane access? | `ALLOWED` | Expected result reflects the final least-privilege design. |
| AT-05 | Is access to the known project-owned negative-control canary denied when the identity has no role assignment on that resource group? | `DENIED` | `DENIED` |

## Future Test Sequence

1. Authenticate as the intentionally created lab service principal using its lab credential.
2. Verify the authenticated identity.
3. Enumerate only accessible resources in `rg-az01-workload-lab`.
4. Enumerate only role assignments relevant to the lab scope.
5. Demonstrate the agreed management-plane excess only within the lab boundary.
6. Demonstrate explicitly authorized data-plane access to synthetic data where applicable.
7. Perform the harmless AT-05 authorization-negative test against the known canary in `rg-az01-negative-control`.
8. Record the effective blast radius and expected denials.

No destructive operation, privilege escalation, enumeration, read, modification, or data access outside the project-owned AZ-01 boundaries is authorized by this plan. The negative-control resource exists solely to prove resource-scope containment.
