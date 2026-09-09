<p align="center">
  <img src="docs/assets/az01-banner.png" alt="AZ-01 Azure Workload Identity Attack and Secretless Federation Lab" width="100%" />
</p>

# AZ-01 — Azure Workload Identity Attack & Secretless Federation Lab

> Attack workload identity. Remove long-lived secrets. Prove bounded least privilege. Preserve the evidence.

[![Phase 6 Security CI](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/actions/workflows/security-ci.yml/badge.svg)](https://github.com/nagasesank/AZ-01-azure-workload-identity-security-lab/actions/workflows/security-ci.yml)

AZ-01 is a controlled Azure security-engineering lab that demonstrates how a copied Microsoft Entra workload credential and excessive Azure RBAC can combine into a practical attack path, then remediates that design with GitHub OIDC, Microsoft Entra workload identity federation, reduced authorization scope, bounded re-attack validation, teardown verification, and repository-level CI/CD hardening.

The project uses **synthetic data and project-owned Azure resources only**. It does not claim production suitability, universal least privilege, HIPAA/HITRUST compliance, or broad Azure security coverage.

## Executive Summary

The vulnerable baseline used a long-lived Microsoft Entra service-principal credential with excessive Azure RBAC. Phase 3 demonstrated only the actions already authorized to that identity inside a bounded lab target set, including a controlled management-plane mutation and access to known synthetic data. A project-owned negative control was used to validate containment.

Phase 4 replaced the long-lived credential path with Microsoft Entra workload identity federation and GitHub OIDC, while reducing the workload authorization scope. Runtime validation confirmed successful OIDC authentication and the intended metadata-only synthetic-blob access.

Phase 5 then re-ran a bounded authorization test matrix. Intended access succeeded while the tested workload resource-group enumeration, benign tag mutation, synthetic blob creation, negative-control access, and account-level container listing received explicit authorization denials. These results apply only to the tested actions and known targets.

The validation environment was subsequently destroyed. Phase 7 verified empty Terraform state and absence of the exact known project-owned Azure resources and workload identity objects. Phase 6 completed repository hardening with static security CI, a controlled CI negative-path test, protected-main rules, least-privilege GitHub Actions defaults, retirement of historical Azure/OIDC workflows, stale repository-variable cleanup, and a bounded Dependabot policy.

**Current cloud state: the AZ-01 Azure validation environment is destroyed.**

## Key Results

| Area | Verified outcome |
| --- | --- |
| Vulnerable baseline | Controlled credential-compromise path demonstrated against known project-owned targets |
| Containment | Negative-control canary access denied |
| Authentication remediation | GitHub OIDC + Microsoft Entra workload identity federation validated |
| Authorization remediation | Intended synthetic-blob metadata access retained; tested excessive actions denied |
| Teardown | Terraform state empty; exact known validation resources and workload identity objects absent |
| CI/CD | Terraform static validation, IaC security scan, and current-content secret scan enforced |
| CI negative path | CF-01 proved the formatting gate rejected a deliberately misformatted runner-only Terraform fixture and accepted remediation |
| Repository hardening | `main` protected by PR + required checks; force-push/deletion blocked; Actions defaults verified read-only |
| Historical runtime paths | Phase 4/5 Azure OIDC workflows disabled after evidence capture |
| Dependency policy | Weekly patch/minor visibility retained; unsupported major-version updates require explicit review |

## Attack → Remediation → Closeout Lifecycle

```text
Long-lived client secret
        → Microsoft Entra application / service principal
        → excessive Azure RBAC
        → controlled credential compromise
        → excessive authorized actions demonstrated
        → vulnerable deployment destroyed
        → fresh secretless deployment
        → GitHub OIDC
        → Entra federated identity credential
        → reduced RBAC scope
        → bounded post-remediation validation
        → intended access succeeds
        → tested excessive actions explicitly denied
        → Terraform destroy
        → bounded post-destroy verification
        → static CI + controlled CI failure validation
        → protected main + least-privilege Actions defaults
        → historical OIDC workflows retired
        → stale repository variables removed
        → project closeout
```

## Security Engineering Objectives

- Model a vulnerable workload identity inside a dedicated lab boundary.
- Validate a controlled credential-compromise path without arbitrary subscription enumeration.
- Use project-owned negative controls to test authorization containment.
- Replace long-lived workload credentials with federated identity.
- Reduce Azure RBAC to the narrowest practical scope required by the workload.
- Re-run controlled tests after remediation and classify denials explicitly.
- Preserve sanitized, reviewable evidence.
- Destroy cloud resources after validation windows.
- Add CI/CD and repository controls that protect the validated source baseline.

## Architecture

The vulnerable design contained a Microsoft Entra application and service principal, a workload resource-group boundary, Azure RBAC, private synthetic storage, and a separate project-owned negative-control resource group with a benign canary.

Phase 4 created a fresh secretless validation deployment using GitHub OIDC and a Microsoft Entra federated identity credential. Workload authorization was reduced to container-scoped read access before the Phase 5 re-attack matrix.

- [Architecture index](docs/architecture/README.md)
- [Phase 1 architecture](docs/architecture/phase-1-architecture.md)
- [Security decisions](docs/architecture/security-decisions.md)
- [Phase 4 remediation](docs/implementation/phase-4-remediation.md)

## Threat Model

The threat model covers credential theft and replay, excessive RBAC, authorization blast radius, trust boundaries, state exposure, federation, least privilege, and evidence safety.

- [Threat-model index](docs/threat-model/README.md)
- [Workload identity threat model](docs/threat-model/workload-identity-threat-model.md)

## Controlled Attack Validation

Phase 3 validated only known project-owned targets. No arbitrary subscription enumeration, production data access, credential harvesting, destructive operations, or general offensive tooling was in scope.

- **AT-01** — vulnerable credential authentication
- **AT-02** — workload resource-group enumeration
- **AT-03** — benign management-plane tag mutation and verified restoration
- **AT-04** — known synthetic blob access
- **AT-05** — negative-control access denied

Evidence:

- [Attack-path index](docs/attack-path/README.md)
- [Phase 1 attack plan](docs/attack-path/phase-1-attack-plan.md)
- [Phase 3 evidence](docs/evidence/phase-3.md)

## Post-Remediation Validation

Phase 5 separated positive-path access from denial checks and treated ambiguous results conservatively.

Verified outcomes included:

- OIDC authentication succeeded.
- Intended metadata access to the exact known synthetic blob succeeded.
- Workload resource-group enumeration was denied.
- Benign tag mutation was denied.
- Dedicated synthetic blob creation was denied.
- Negative-control canary access was denied.
- Account-level container listing against the known workload storage account was denied.
- Mutation probes ran separately and session cleanup passed.

These findings demonstrate only the tested authorization behavior. They do not prove universal denial, universal least privilege, or production security.

- [Phase 5 runtime validation](docs/evidence/phase-5-runtime-validation.md)

## Teardown and Cleanup

The later Phase 4/5 validation deployment was destroyed after evidence capture. Bounded post-destroy checks verified:

- empty Terraform state;
- absence of the exact known workload resource group;
- absence of the exact known negative-control resource group;
- absence of the known workload Microsoft Entra application;
- absence of the known workload service principal;
- removal of Phase 5 GitHub repository secrets.

- [Phase 7 teardown validation](docs/evidence/phase-7-teardown-validation.md)

## CI/CD and Repository Hardening

Phase 6 adds a static security gate without recreating the Azure environment.

The `Phase 6 Security CI` workflow runs on pull requests and pushes to `main` with explicit `contents: read` permission and three required jobs:

- `terraform-static-validation`
- `iac-security-scan`
- `secret-scan`

The Terraform job performs formatting checks, backend-free provider initialization, and configuration validation. Trivy provides IaC and current-content secret scanning. The reviewed lab-specific `AZU-0012` exception remains narrowly scoped and time-bounded.

CF-01 validated the negative path by creating a deliberately misformatted but valid Terraform fixture only under runner temporary storage, proving the formatting gate rejected it, remediating it, revalidating it, cleaning it up, and then intentionally failing the controlled run. The production CI workflow was restored with zero net workflow change.

Repository closeout additionally verified:

- active protection for `main` requiring pull requests and the three CI checks;
- branch-up-to-date enforcement for required checks;
- force-push and branch-deletion protection;
- read-only default GitHub Actions workflow permissions;
- workflow PR approval disabled;
- historical Phase 4/5 Azure OIDC workflows disabled without rewriting their YAML provenance;
- stale historical repository variables removed by name-only cleanup;
- weekly Dependabot visibility retained while semver-major migrations require explicit compatibility review.

- [Phase 6 CI/CD plan](docs/implementation/phase-6-cicd-security-plan.md)
- [Phase 6 CI/CD implementation](docs/implementation/phase-6-cicd-security-controls.md)
- [Phase 6 controlled failure validation](docs/implementation/phase-6-controlled-failure-validation.md)
- [Phase 6 repository hardening](docs/implementation/phase-6-repository-hardening.md)
- [Project retrospective](docs/implementation/project-retrospective.md)

## Evidence

Evidence follows a hierarchy of verified outputs, sanitized screenshots, and concise written records. Public evidence excludes credentials, tokens, identifiers, Terraform state/plans, CLI caches, and unnecessary environment details.

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
.github/                  Static security CI, Dependabot policy, historical OIDC workflows
docs/
  architecture/           Architecture and security decisions
  attack-path/            Controlled attack plans and validation design
  evidence/               Validation records and sanitized screenshots
  implementation/         Phase implementation, hardening, and retrospective records
  threat-model/           Threat-model documentation
scripts/                  Local validation and historical bounded test harnesses
terraform/                Validated Terraform source baseline
README.md                 Project entry point
LICENSE                   Project license
```

Documentation indexes: [docs](docs/README.md), [architecture](docs/architecture/README.md), [attack path](docs/attack-path/README.md), [evidence](docs/evidence/README.md), [implementation](docs/implementation/README.md), [threat model](docs/threat-model/README.md), [scripts](scripts/README.md), [Terraform](terraform/README.md), and [.github](.github/README.md).

## Technology Stack

- Terraform `>= 1.10.0`
- HashiCorp AzureRM, AzureAD, and Random providers
- Microsoft Azure and Microsoft Entra ID
- Azure RBAC
- Azure Storage with synthetic data only
- GitHub Actions
- GitHub OIDC / Microsoft Entra workload identity federation
- Azure CLI for owner-operated validation windows
- PowerShell
- Trivy for IaC and current-content secret scanning

## Reproducing the Lab

The repository preserves the implementation and evidence, but **no live AZ-01 Azure validation environment currently exists**. Any future replay should be treated as a new controlled validation window and must re-review provider compatibility, the time-bounded Trivy exception, Azure authorization scope, current GitHub settings, and evidence-sanitization requirements before deployment.

For an authorized replay, see:

- [Terraform guide](terraform/README.md)
- [Script guide](scripts/README.md)
- [Security decisions](docs/architecture/security-decisions.md)

## Engineering Workflow

```text
CREATE → Terraform apply → validate → capture evidence
       → inject controlled attack/failure
       → investigate → remediate → revalidate → capture evidence
       → Terraform destroy → verify cleanup
       → harden CI/repository controls → close out
```

This workflow intentionally separates build, validation, controlled failure, remediation, cleanup, and evidence review.

## Security and Evidence Hygiene

Never commit client secrets, access tokens, refresh tokens, Terraform state, tfplan files, Azure CLI caches, `.env` secrets, subscription IDs, tenant IDs, application/client IDs, object/principal IDs, or unsanitized runtime evidence.

Historical validation workflows remain in source control for provenance but are disabled. Re-enabling them requires a new explicit authorization and review cycle.

## Cost Control

The lab avoids VM-heavy architecture and uses small synthetic resources only. Infrastructure existed only during controlled validation windows and was destroyed after testing. This repository does not publish fabricated cost estimates.

## Project Phases

| Phase | Status |
| --- | --- |
| 0 — Repository/Azure connectivity | Complete |
| 1 — Architecture/threat modeling | Complete |
| 2 — Vulnerable identity infrastructure | Complete |
| 3 — Credential-compromise validation | Complete |
| 4 — GitHub OIDC + least privilege | Complete |
| 5 — Re-attack/security validation | Complete |
| 6 — CI/CD security controls and repository hardening | Complete |
| 7 — Evidence, teardown, cleanup, and retrospective | Complete |

## Final Project State

```text
Phase 3 vulnerable baseline: COMPLETE
Phase 4 OIDC remediation/runtime validation: COMPLETE
Phase 5 post-remediation validation: COMPLETE
Phase 6 static CI + controlled failure + repository hardening: COMPLETE
Phase 7 teardown/cleanup verification: COMPLETE
Project retrospective: COMPLETE
Current AZ-01 Azure validation environment: DESTROYED
Historical Azure OIDC validation workflows: DISABLED
Long-lived client secret: NOT RECREATED
```

AZ-01 is now closed as a **synthetic, evidence-driven cloud-security lab**. Future maintenance or redeployment should start from the preserved evidence and validated source baseline, not assume the 2026 runtime results still represent current Azure, provider, or GitHub behavior.
