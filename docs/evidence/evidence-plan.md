# Evidence Plan

Later phases will capture the following verified evidence:

- Terraform plan and Terraform apply.
- Azure CLI resource validation.
- Microsoft Entra application and service-principal evidence.
- Role assignment evidence.
- Vulnerable authentication result and resource enumeration result.
- Excessive privilege demonstration and synthetic-data data-plane test.
- AT-05 negative-control canary denied-access result, showing no workload service-principal role assignment on that project-owned resource group.
- Client-secret removal evidence.
- Federated credential and GitHub OIDC authentication evidence.
- Post-remediation denied-access evidence.
- Terraform destroy and Azure CLI confirmation that resources were removed.

Evidence is captured only after the associated action has occurred. Before any screenshot or artifact is published, redact identifiers, credentials, tokens, tenant IDs, subscription IDs, and all other sensitive values. Evidence must not include production, personal, customer, healthcare, credential, or other sensitive data. AT-05 evidence must be limited to the known project-owned negative-control canary and must never document testing against arbitrary subscription resources.
