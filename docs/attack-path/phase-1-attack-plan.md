# Phase 1 Controlled Attack Plan

## Scope and Safety

This is a future, controlled test plan, not an attack execution record. The assumed compromise is possession of the intentionally created lab credential. Authentication proves the service principal identity; authorization determines which management-plane and data-plane actions it can perform. All future activity is limited to the dedicated AZ-01 resource group and synthetic data.

| Test | Security Question | Vulnerable Expected Result | Remediated Expected Result |
| ---- | ----------------- | -------------------------- | -------------------------- |
| AT-01 | Can the intentionally exposed lab service-principal credential authenticate? | `ALLOWED` | `DENIED` after client secret removal. |
| AT-02 | Can the identity enumerate resources in the dedicated AZ-01 resource group? | `ALLOWED` | Only intended scope/actions allowed. |
| AT-03 | Can the identity perform an intentionally excessive management-plane action on an AZ-01 lab resource? | `ALLOWED` | `DENIED` if outside required workload permissions. |
| AT-04 | Can the identity access synthetic data when deliberately granted data-plane access? | `ALLOWED` | Expected result reflects the final least-privilege design. |
| AT-05 | Can the identity access anything outside the AZ-01 resource-group boundary? | `DENIED` | `DENIED` |

## Future Test Sequence

1. Authenticate as the intentionally created lab service principal using its lab credential.
2. Verify the authenticated identity.
3. Enumerate only accessible resources in the dedicated resource group.
4. Enumerate only role assignments relevant to the lab scope.
5. Demonstrate the agreed management-plane excess only within the lab boundary.
6. Demonstrate explicitly authorized data-plane access to synthetic data where applicable.
7. Record the effective blast radius and expected denials.

No destructive operation, privilege escalation, enumeration, or data access outside the dedicated lab boundary is authorized by this plan.
