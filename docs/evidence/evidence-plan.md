# Evidence Plan

The repository preserves the following verified evidence across the project lifecycle:

- Terraform plan and Terraform apply evidence for approved deployment windows.
- Azure CLI resource validation.
- Microsoft Entra application and service-principal evidence.
- Role assignment evidence.
- Vulnerable authentication result and resource enumeration result.
- Excessive privilege demonstration and synthetic-data data-plane test.
- AT-05 negative-control canary denied-access result, showing no workload service-principal role assignment on that project-owned resource group.
- Client-secret removal evidence.
- Federated credential and GitHub OIDC authentication evidence.
- Post-remediation denied-access evidence.
- Terraform destroy and bounded Azure CLI confirmation that the exact known validation resources were removed.
- Removal and absence verification for the Phase 5 GitHub repository secrets used by the validation workflow.

Phase 7 teardown evidence completed on 2026-09-09. It records successful Terraform destroy, empty Terraform state, absence of the exact known workload and negative-control resource groups, absence of the exact workload Entra application and service principal, and absence of the Phase 5 GitHub repository secrets. These checks do not establish universal subscription-wide cleanup.

Evidence is captured only after the associated action has occurred. Before any screenshot or artifact is published, redact identifiers, credentials, tokens, tenant IDs, subscription IDs, and all other sensitive values. Evidence must not include production, personal, customer, healthcare, credential, or other sensitive data. AT-05 evidence must be limited to the known project-owned negative-control canary and must never document testing against arbitrary subscription resources.

See [Phase 7 teardown validation](phase-7-teardown-validation.md) for the final bounded cleanup record for the Phase 4/5 validation deployment.
