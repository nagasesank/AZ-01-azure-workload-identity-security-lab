# Phase 2 Deployment and State Security

Phase 2 is Terraform code only until an owner/operator intentionally runs it locally. No deployment evidence is recorded by this document.

## Sensitive State

The temporary vulnerable-phase application password may exist in local Terraform state. Treat `terraform.tfstate`, `terraform.tfstate.backup`, and generated plan files as sensitive. Never commit them, include them in screenshots, upload them as evidence, or copy their values into documentation.

The temporary credential is revoked in Phase 4. Final project teardown destroys the Microsoft Entra objects and Azure resources.

## Safe Local Execution

Do not run Terraform that contains generated credentials from an automatically synchronized consumer-cloud-storage directory. Use a local, non-synchronized working directory with appropriate access controls. Do not place credentials in `.tfvars`, environment files committed to the repository, GitHub secrets, or documentation.

## Operator Provisioning Access

Shared Key storage authorization is disabled so Phase 2 data-plane behavior is governed by Microsoft Entra and Azure RBAC. The currently authenticated Terraform operator receives `Storage Blob Data Contributor` only at the workload storage-account scope so Terraform can create the private container and synthetic blob. This is provisioning-only infrastructure ownership; it is not assigned to the vulnerable service principal and is not part of the attack surface or its exact-two-role validation.

## Runtime Validation

After a deliberate local apply, the owner/operator may run `scripts/validate-phase2.ps1`. The script validates only non-secret outputs and owner-context configuration; it does not authenticate as the vulnerable service principal, read its client password, or run attack tests.
