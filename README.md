# AZ-01 - Azure Workload Identity Attack & Secretless Federation Lab

> Attack workload identity. Remove long-lived secrets. Prove least privilege.

AZ-01 is a controlled Azure security-engineering lab that records a deliberately vulnerable workload identity, validates its constrained attack path, and preserves a factual baseline for remediation and revalidation.

## Executive Summary

The lab models the risk of a long-lived Microsoft Entra service-principal credential combined with excessive Azure RBAC. Phase 3 validated a controlled credential-compromise path only against project-owned resources and synthetic data. Terraform is the infrastructure source of truth.

Phase 4 implemented Microsoft Entra workload identity federation, GitHub OIDC, and reduced authorization scope. Owner-operated runtime validation successfully verified OIDC authentication and the intended metadata-only synthetic-blob read on 2026-09-09.

Phase 5 completed bounded post-remediation authorization validation on 2026-09-09 across three reviewed dispatches. The tested authorization denials and successful intended access are recorded in the [Phase 5 runtime validation](docs/evidence/phase-5-runtime-validation.md). The associated screenshots were published and reviewed.

The later Phase 4/5 validation deployment was then destroyed through the owner-operated Terraform workflow. Bounded post-destroy checks verified empty Terraform state, absence of the exact known project-owned Azure targets, and removal of the Phase 5 GitHub repository secrets. See the [Phase 7 teardown validation](docs/evidence/phase-7-teardown-validation.md).

## Security Problem

Long-lived credentials can be copied and replayed. Excessive RBAC expands the actions available after authentication. Credential security and authorization scope must both be addressed: removing a secret alone does not correct excessive permissions, and narrowing permissions alone does not prevent credential replay.

## Security Engineering Objectives

- Model a vulnerable workload identity in a dedicated lab boundary.
- Validate a controlled attack path and its authorization impact.
- Maintain a project-owned negative control outside the workload authorization boundary.
- Replace long-lived secrets with federated identity.
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
        -> later secretless deployment                  [Phase 4 complete]
        -> GitHub OIDC                                  [Phase 4 validated]
        -> Entra federated identity credential          [Phase 4 complete]
        -> reduced RBAC scope                           [Phase 4 complete]
        -> bounded post-remediation tests               [Phase 5 complete]
        -> tested actions/targets explicitly denied     [Phase 5 validated]
        -> owner-operated Terraform destroy             [Phase 7 complete]
        -> bounded cleanup verification                 [Phase 7 complete]
```

## Architecture

The verified vulnerable design contained a Microsoft Entra application and service principal, a workload resource-group boundary, Azure RBAC, private synthetic storage, and a separate project-owned negative-control resource group with a benign canary. Phase 4 established a fresh secretless deployment with GitHub OIDC and container-scoped read access; OIDC authentication and the intended synthetic-blob metadata read were runtime-verified before teardown.

- [Architecture index](docs/architecture/README.md)
- [Phase 1 architecture](docs/architecture/phase-1-architecture.md)
- [Security decisions](docs/architecture/security-decisions.md)
- [Phase 4 remediation](docs/implementation/phase-4-remediation.md)

## Threat Model

The threat model covers secret theft and replay, excessive RBAC, authorization blast radius, trust boundaries, state exposure, federation, and least-privilege controls.

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
- The Phase 2/3 vulnerable lab was destroyed after evidence capture for cost control.
- Phase 4 GitHub OIDC authentication and intended synthetic blob metadata read succeeded.
- Phase 5 OIDC authentication and metadata access to the exact known synthetic blob succeeded.
- Phase 5 tested workload-RG resource enumeration and benign tag mutation received explicit authorization denials.
- Phase 5 creation of the dedicated synthetic write-probe blob was denied; the baseline blob was not overwritten.
- Phase 5 access to the known negative-control canary and account-level container listing against the known workload storage account were denied.
- Phase 5 RT-03 and RT-04W ran separately; session cleanup passed in all three dispatches. These results apply only to the tested actions and targets, not universal authorization denial.
- Phase 5 evidence screenshots were published and reviewed.
- The later Phase 4/5 validation deployment was destroyed through Terraform after evidence capture.
- Post-destroy checks verified empty Terraform state and absence of the exact known workload resource group, negative-control resource group, workload Entra application, and workload service principal.
- The Phase 5 GitHub repository secrets were removed and verified absent.

**Future work**

- Final review of [Phase 6 repository hardening](docs/implementation/phase-6-repository-hardening.md) and the [project retrospective](docs/implementation/project-retrospective.md). Static CI, controlled failure validation, repository controls, OIDC workflow retirement, and stale-variable cleanup are verified.

## Evidence

Evidence follows a hierarchy of verified outputs, sanitized screenshots, and concise written records. Public evidence excludes secrets, identifiers, tokens, state, plans, and unnecessary environment details.

- [Evidence index](docs/evidence/README.md)
- [Evidence plan](docs/evidence/evidence-plan.md)
- [Phase 2 validation](docs/evidence/phase-2-validation.md)
- [Phase 3 validation](docs/evidence/phase-3.md)
- [Phase 4 runtime validation](docs/evidence/phase-4-runtime-validation.md)
- [Phase 5 runtime validation](docs/evidence/phase-5-runtime-validation.md)
- [Phase 7 teardown validation](docs/evidence/phase-7-teardown-validation.md)
- [Phase 2 screenshots](docs/evidence/screenshots/phase-2/)
- [Phase 3 screenshots](docs/evidence/screenshots/phase-3/)
- [Phase 4 screenshots](docs/evidence/screenshots/phase-4/)
- [Phase 5 screenshots](docs/evidence/screenshots/phase-5/)
- [Phase 7 screenshots](docs/evidence/screenshots/phase-7/)

## Repository Structure

```text
.github/                 GitHub Actions validation and future Phase 6 controls
docs/
  architecture/          Architecture and security decisions
  attack-path/           Controlled attack plans
  evidence/              Validation records and sanitized screenshots
  implementation/        Phase implementation records
  threat-model/           Threat model documentation
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
- GitHub Actions manual OIDC validation workflow, runtime-validated

## Local Prerequisites

- Terraform `>= 1.10.0`
- Azure CLI with an existing `az login` session for an approved validation deployment
- `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` matching that Azure CLI account
- PowerShell

See the [Terraform guide](terraform/README.md) and [script guide](scripts/README.md) for the owner-operated workflow.

## Engineering Workflow

```text
CREATE -> Terraform apply -> validate -> evidence -> controlled attack/failure
       -> investigate -> remediate -> revalidate -> evidence
       -> Terraform destroy -> cleanup verification
```

Live Azure resources are kept only for required, owner-operated validation windows. The Phase 2/3 vulnerable lab and the later Phase 4/5 secretless validation deployment have both been destroyed after their evidence windows.

## Security and Evidence Hygiene

Never commit client secrets, access tokens, refresh tokens, Terraform state, tfplan files, Azure CLI caches, `.env` secrets, subscription IDs, tenant IDs, application/client IDs, or object/principal IDs in public evidence. Screenshots must be sanitized before publication.

## Cost Control

The lab avoids VM-heavy architecture and uses small synthetic resources only. Infrastructure is deployed only for controlled validation windows and destroyed after testing. This repository does not publish fabricated cost estimates.

## Project Phases

| Phase | Status |
| --- | --- |
| 0 - Repository/Azure connectivity | Complete |
| 1 - Architecture/threat modeling | Complete |
| 2 - Vulnerable identity infrastructure | Complete |
| 3 - Credential-compromise validation | Complete |
| 4 - GitHub OIDC + least privilege | Complete (GitHub OIDC authentication and intended synthetic blob metadata read validated) |
| 5 - Re-attack/security validation | Complete (bounded post-remediation authorization validation and evidence review complete) |
| 6 - CI/CD security controls | Controls implemented and verified; final evidence/closeout review pending |
| 7 - Evidence/cleanup/retrospective | Teardown/cleanup evidence complete; retrospective prepared for review |

## Current Status

```text
Phase 3: COMPLETE
Phase 4: COMPLETE
Phase 5: POST-REMEDIATION VALIDATION COMPLETE
Phase 5 evidence review: COMPLETE
Phase 6: REPOSITORY CONTROLS VERIFIED; FINAL EVIDENCE/CLOSEOUT REVIEW PENDING
Phase 7 teardown/cleanup evidence: COMPLETE
Final retrospective/project closeout: PREPARED; REVIEW PENDING
Current AZ-01 Azure validation environment: DESTROYED
```
