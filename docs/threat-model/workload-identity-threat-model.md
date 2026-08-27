# Workload Identity Threat Model

## Assets

- Workload identity and client credential.
- Federated identity configuration.
- Azure role assignments.
- Synthetic test data.
- Terraform configuration and Terraform state.
- GitHub repository and workflow.

## Threat Actors

- An attacker possessing a leaked workload credential.
- A malicious or compromised CI/CD context.
- A developer accidentally exposing credentials.

## Trust Boundaries

- GitHub to Microsoft Entra.
- Microsoft Entra to Azure Resource Manager.
- Azure Resource Manager to target resources.
- Management plane to data plane.
- Local administrator/test operator to Azure.

## Threat Scenarios

| Scenario | Precondition | Attack | Impact | Planned Control | Validation Method |
| --- | --- | --- | --- | --- | --- |
| Long-lived client secret theft | A lab secret exists and is exposed. | Authenticate with the stolen secret. | Persistent impersonation of the lab workload. | Remove the secret; use GitHub OIDC. | AT-01 is denied after remediation. |
| Credential replay | An attacker retains a valid lab credential. | Reuse it from another context. | Unauthorized workload authentication. | Eliminate long-lived credentials and constrain federated subject claims. | Attempt repeat authentication after secret removal. |
| Excessive Azure RBAC | The lab identity has more control-plane permission than needed. | Perform the agreed excessive action within the lab resource group. | Excessive control over lab resources. | Least-privilege RBAC at the narrowest scope. | AT-03 is denied after remediation. |
| Excessive resource scope | A role assignment reaches beyond the lab boundary. | Enumerate or act outside the lab resource group. | Blast radius beyond the lab. | Dedicated resource-group scope; no subscription-wide roles. | AT-05 remains denied. |
| Data-plane privilege abuse | Explicit data-plane access to synthetic data is granted. | Read or act on synthetic data. | Exposure or alteration of test data. | Minimize data-plane permissions and use synthetic data only. | AT-04 matches the final least-privilege design. |
| Malicious workflow modification | A contributor can alter a workflow or branch policy is weak. | Change workflow identity use or exfiltrate a credential. | CI/CD identity misuse. | Protected branches, reviewed workflows, OIDC subject restrictions. | Review workflow and repository controls in a later phase. |
| Federated credential subject misconfiguration | A federated credential is too broad. | Obtain a token from an unintended repository, branch, or environment. | Unauthorized CI/CD identity use. | Exact repository and branch/environment subject claims. | Attempt an out-of-scope subject in a controlled test. |
| Terraform state disclosure | State contains sensitive configuration and is exposed. | Read local or remote state. | Credential or infrastructure disclosure. | Ignore state files, restrict storage, redact evidence. | Repository and storage access review. |
| Accidental credential commit | A developer adds a secret or token to Git. | Retrieve it from history or a fork. | Credential compromise. | `.gitignore`, secret scanning, review, and immediate rotation/removal. | Pre-commit and pull-request review. |

## Boundary Statement

This lab intentionally models credential compromise and excessive authorization, but never tenant-wide or subscription-wide privileged access. The target boundary is the dedicated AZ-01 resource group; all data is synthetic.
