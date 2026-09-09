# Phase 4 Secretless OIDC and Least-Privilege Remediation

Phase 4 prepares the remediated Terraform desired state and a manual GitHub Actions validation workflow. Runtime deployment and validation are pending.

## Redeployment Model

The vulnerable Phase 2/3 Azure environment was destroyed after Phase 3 evidence capture for cost control. Phase 4 does not remediate a currently running vulnerable service principal in place.

1. Phase 2/3 evidence preserves the vulnerable-state baseline.
2. Phase 4 changes Terraform to the remediated desired state.
3. The remediated architecture will be freshly deployed for a short owner-operated validation window.
4. Phase 5 will compare post-remediation behavior with the preserved Phase 3 evidence.
5. The final environment will be destroyed again after evidence capture.

## Remediated Identity and Authorization

The workload application and service principal have no application password. GitHub Actions is trusted through one federated identity credential with this exact tuple:

- Issuer: `https://token.actions.githubusercontent.com`
- Audience: `api://AzureADTokenExchange`
- Subject: `repo:nagasesank/AZ-01-azure-workload-identity-security-lab:ref:refs/heads/main`

The workload receives only `Storage Blob Data Reader` at the synthetic-data container Resource Manager scope. It has no Contributor, management-plane Reader, storage write, storage owner, or negative-control resource-group role assignment.

## Owner Runtime Configuration

After this implementation is reviewed, merged, and deployed by the owner, configure these GitHub repository variables:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZ01_STORAGE_ACCOUNT`

These are identifiers or resource configuration rather than a password, but public evidence must still avoid publishing their actual values. Do not create a secret variable for Azure authentication.

From an owner-controlled shell after deployment, GitHub CLI can set the variables from Terraform outputs without printing values:

```powershell
Push-Location terraform
try {
    gh variable set AZURE_CLIENT_ID --repo nagasesank/AZ-01-azure-workload-identity-security-lab --body (terraform output -raw workload_application_client_id)
    gh variable set AZURE_TENANT_ID --repo nagasesank/AZ-01-azure-workload-identity-security-lab --body (terraform output -raw current_tenant_id)
    gh variable set AZURE_SUBSCRIPTION_ID --repo nagasesank/AZ-01-azure-workload-identity-security-lab --body (terraform output -raw current_subscription_id)
    gh variable set AZ01_STORAGE_ACCOUNT --repo nagasesank/AZ-01-azure-workload-identity-security-lab --body (terraform output -raw workload_storage_account_name)
}
finally {
    Pop-Location
}
```

Run these commands only in an owner-controlled environment. Do not echo Terraform output values, publish them in logs or screenshots, or place them in committed files.

## Manual Workflow

The [Phase 4 OIDC validation workflow](../../.github/workflows/phase-4-oidc-validation.yml) is manual-only. It uses GitHub OIDC with repository variables, confirms authentication with a sanitized marker, and performs metadata-only Azure Storage validation of the known private synthetic blob through Microsoft Entra authentication. It does not print blob contents or mutate Azure resources.

This workflow has not been run. Successful OIDC authentication and least-privilege behavior must be established by future owner-operated runtime validation.
