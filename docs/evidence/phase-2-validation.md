# Phase 2 Validation

## Verified Results

- Owner-operated Terraform deployment completed successfully.
- The final drift plan reported no changes.
- Owner-context validation passed.
- The vulnerable service principal had exactly two direct Azure RBAC assignments.
- Contributor was restricted to the workload resource-group boundary.
- Storage Blob Data Contributor was restricted to the workload storage-account boundary.
- The negative-control boundary had zero vulnerable service-principal role assignments.
- Shared Key authorization was disabled.
- The private synthetic-data container and synthetic test blob were validated with Microsoft Entra authentication.
- All test data is synthetic.
- No Phase 3 attack tests were executed.

## Evidence Handling

No screenshots, Terraform state, client secret, access token, subscription ID, tenant ID, client ID, object ID, generated storage-account name, or other environment identifier is retained in this record.
