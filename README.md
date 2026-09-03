# AZ-01 - Azure Workload Identity Attack & Secretless Federation Lab

> Attack workload identity. Remove long-lived secrets. Prove least privilege.

AZ-01 is a controlled Azure security-engineering lab that records a deliberately vulnerable workload identity, validates its constrained attack path, and preserves a factual baseline for future remediation.

## Executive Summary

The lab models the risk of a long-lived Microsoft Entra service-principal credential combined with excessive Azure RBAC. Phase 3 validated a controlled credential-compromise path only against project-owned resources and synthetic data. Terraform is the infrastructure source of truth.

The upcoming remediation work will replace the long-lived credential with Microsoft Entra workload identity federation and GitHub OIDC, reduce authorization scope, and re-run the controlled tests. Phase 4 remediation is not implemented.

## Security Problem

Long-lived credentials can be copied and replayed. Excessive RBAC expands the actions available after authentication. Credential security and authorization scope must both be addressed: removing a secret alone does not correct excessive permissions, and narrowing permissions alone does not prevent credential replay.

## Security Engineering Objectives

- Model a vulnerable workload identity in a dedicated lab boundary.
- Validate a controlled attack path and its authorization impact.
- Maintain a project-owned negative control outside the workload authorization boundary.
- Replace long-lived secrets with federated identity in a future phase.
- Reduce Azure RBAC to the narrowest practical scope.
- Re-run controlled tests after remediation.
- Preserve verified, sanitized evidence.
- Destroy lab resources after validation windows.

## Attack -> Remediation Lifecycle

```text
Long-lived client secret
        -> Microsoft Entra application / service principal
        -> excessive Azure RBAC
        -> controlled credential compromise
        -> excessive authorized actions demonstrated
        -> remove long-lived credential                 [Phase 4/5 future work]
        -> GitHub OIDC                                  [Phase 4/5 future work]
        -> Entra federated identity credential          [Phase 4/5 future work]
        -> least-privilege RBAC                         [Phase 4/5 future work]
        -> repeat attack tests                          [Phase 4/5 future work]
        -> unauthorized actions denied                  [Phase 4/5 future work]
```

## Architecture

The verified vulnerable design contains a Microsoft Entra application and service principal, a workload resource-group boundary, Azure RBAC, private synthetic storage, and a separate project-owned negative-control resource group with a benign canary. Federation remediation is future work.

- [Architecture index](docs/architecture/README.md)
- [Phase 1 architecture](docs/architecture/phase-1-architecture.md)
- [Security decisions](docs/architecture/security-decisions.md)

## Threat Model

The threat model covers secret theft and replay, excessive RBAC, authorization blast radius, trust boundaries, state exposure, and planned federation and least-privilege controls.

- [Threat-model index](docs/threat-model/README.md)
- [Workload identity threat model](docs/threat-model/workload-identity-threat-model.md)

## Controlled Attack Validation

Phase 3 validated only known project-owned targets. No arbitrary subscription enumeration, production data, or general offensive tooling is in scope.

- AT-01: vulnerable credential authentication.
- AT-02: workload resource-group enumeration.
- AT-03: harmless management-plane tag mutation and restoration.
- AT-04: synthetic blob access.
- AT-05: negative-control access denied.

- [Attack-path index](docs/attack-path/README.md)
- [Phase 1 attack plan](docs/attack-path/phase-1-attack-plan.md)
- [Phase 3 evidence](docs/evidence/phase-3.md)

## Verified Project Results

**Verified**

- Phase 0 Terraform and Azure CLI connectivity validation completed.
- Phase 1 architecture and threat modeling completed.
- Phase 2 vulnerable identity infrastructure was deployed and owner-validated.
- Phase 3 AT-01 through AT-05 completed successfully; AT-03 restoration and AT-05 containment were verified.
- The lab was destroyed after Phase 3 evidence capture for cost control.

**Future work**

- GitHub OIDC and Microsoft Entra federated identity credentials.
- Least-privilege Azure RBAC.
- Post-remediation re-attack and security validation.
- CI/CD security controls and final retrospective.

## Evidence

Evidence follows a hierarchy of verified outputs, sanitized screenshots, and concise written records. Public evidence excludes secrets, identifiers, tokens, state, and unnecessary environment details.

- [Evidence index](docs/evidence/README.md)
- [Evidence plan](docs/evidence/evidence-plan.md)
- [Phase 2 validation](docs/evidence/phase-2-validation.md)
- [Phase 3 validation](docs/evidence/phase-3.md)
- [Phase 2 screenshots](docs/evidence/screenshots/phase-2/)
- [Phase 3 screenshots](docs/evidence/screenshots/phase-3/)

## Repository Structure

```text
.github/                 Future CI/CD workflow area
docs/
  architecture/          Architecture and security decisions
  attack-path/           Controlled attack plans
  evidence/              Validation records and sanitized screenshots
  implementation/        Phase implementation records
  threat-model/          Threat model documentation
scripts/                 Local validation and historical attack harnesses
terraform/               Terraform source of truth
README.md                Project entry point
LICENSE                  Project license
```

Each documentation area has an index: [docs](docs/README.md), [architecture](docs/architecture/README.md), [attack path](docs/attack-path/README.md), [evidence](docs/evidence/README.md), [implementation](docs/implementation/README.md), [threat model](docs/threat-model/README.md), [scripts](scripts/README.md), [Terraform](terraform/README.md), and [.github](.github/README.md).

## Technology Stack

- Terraform `>= 1.10.0`
- HashiCorp AzureRM, AzureAD, and Random providers
- Azure CLI and local Azure CLI authentication
- Microsoft Entra ID and Azure RBAC
- Azure Storage with synthetic data only
- PowerShell
- GitHub Actions and GitHub OIDC as future work

## Local Prerequisites

- Terraform `>= 1.10.0`
- Azure CLI with an existing `az login` session for the intended subscription
- `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` matching that Azure CLI account
- PowerShell

See the [Terraform guide](terraform/README.md) and [script guide](scripts/README.md) for the non-destructive local validation workflow.

## Engineering Workflow

```text
CREATE -> Terraform apply -> validate -> evidence -> controlled attack/failure
       -> investigate -> remediate -> revalidate -> evidence
       -> Terraform destroy -> cleanup verification
```

Live Azure resources are kept only for required, owner-operated validation windows. Terraform apply and destroy are owner-operated actions; the Phase 2/3 lab has already been destroyed.

## Security and Evidence Hygiene

Never commit client secrets, access tokens, refresh tokens, Terraform state, tfplan files, Azure CLI caches, `.env` secrets, subscription IDs, tenant IDs, application/client IDs, or object/principal IDs in public evidence. Screenshots must be sanitized before publication.

## Cost Control

The lab avoids VM-heavy architecture and uses small synthetic resources only. Infrastructure is deployed only for controlled validation windows. The Phase 3 environment was destroyed after evidence capture for cost control; future environments will be destroyed after testing as well. This repository does not publish fabricated cost estimates.

## Project Phases

| Phase | Status |
| --- | --- |
| 0 - Repository/Azure connectivity | Complete |
| 1 - Architecture/threat modeling | Complete |
| 2 - Vulnerable identity infrastructure | Complete |
| 3 - Credential-compromise validation | Complete |
| 4 - GitHub OIDC + least privilege | Not Started |
| 5 - Re-attack/security validation | Not Started |
| 6 - CI/CD security controls | Not Started |
| 7 - Evidence/cleanup/retrospective | Not Started |

## Current Status

```text
Phase 3: COMPLETE
Azure resources: DESTROYED
Phase 4: NOT STARTED
```
