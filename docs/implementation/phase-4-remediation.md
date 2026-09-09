# Phase 4 Secretless OIDC and Least-Privilege Remediation

Phase 4 defines the remediated Terraform desired state and a manual GitHub Actions validation workflow. Owner-operated runtime validation completed successfully on 2026-09-09.

## Redeployment Model

The vulnerable Phase 2/3 Azure environment was destroyed after Phase 3 evidence capture for cost control. Phase 4 deployed a fresh remediated environment rather than changing the vulnerable service principal in place.

1. Phase 2/3 evidence preserves the vulnerable-state baseline.
2. Phase 4 changes Terraform to the remediated desired state.
3. The remediated architecture is deployed only for the owner-operated validation window.
4. Phase 5 will compare post-remediation authorization behavior with the preserved Phase 3 evidence.
5. The final environment will be destroyed after the remaining evidence is captured.

## Remediated Identity and Authorization

The workload application and service principal have no application password. GitHub Actions is trusted through one federated identity credential restricted to:

- Issuer: GitHub Actions OIDC.
- Audience: Microsoft Entra token exchange.
- Subject: this repository's immutable owner/repository identity and the `main` branch.

Literal owner, repository, tenant, subscription, application, object, principal, and resource identifiers are intentionally excluded from public documentation.

The workload receives only `Storage Blob Data Reader` at the known synthetic-data container Resource Manager scope. Terraform defines no Contributor, management-plane Reader, storage write, storage owner, or negative-control resource-group role assignment for the workload identity.

## Owner Runtime Configuration

The owner configured the required GitHub repository variables directly from an owner-controlled environment. The variable names are documented in the workflow; their values are not recorded in public evidence.

No GitHub secret is used for Azure authentication. Values must not be echoed, copied into logs or screenshots, or placed in committed files.

## Manual Workflow

The [Phase 4 OIDC validation workflow](../../.github/workflows/phase-4-oidc-validation.yml) is manual-only. It uses GitHub OIDC with repository variables, confirms authentication with a sanitized marker, and performs metadata-only validation of the known private synthetic blob through Microsoft Entra authentication. It does not print blob contents or mutate Azure resources.

The workflow completed successfully on 2026-09-09. It verified GitHub OIDC authentication and metadata-only read access to the known synthetic blob. See the [Phase 4 runtime-validation evidence](../evidence/phase-4-runtime-validation.md).

Denied-access and re-attack assertions remain Phase 5 work. This successful positive-path read test does not by itself prove the absence of broader permissions.
