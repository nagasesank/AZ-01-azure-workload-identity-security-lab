# Documentation Guide

This directory is the navigation hub for AZ-01 design records, implementation records, validation evidence, teardown records, and future CI/CD hardening work.

## Documentation Areas

- [Architecture](architecture/README.md): system boundaries and security decisions.
- [Attack path](attack-path/README.md): controlled lab-test scope and sequence.
- [Threat model](threat-model/README.md): assets, threats, and planned controls.
- [Implementation](implementation/README.md): verified implementation and remediation records.
- [Evidence](evidence/README.md): verified validation and teardown records with sanitized screenshots.

## Documentation Lifecycle

```text
Design -> implementation -> validation -> evidence -> remediation -> revalidation -> teardown
```

Phase 3 evidence remains the immutable vulnerable, pre-remediation baseline except for factual or redaction corrections. Phase 4 and Phase 5 use a later secretless deployment and remain separate from the historical Phase 3 attack results.

Phase 4 OIDC authentication and intended synthetic-blob metadata read validation completed successfully on 2026-09-09. Phase 5 bounded post-remediation authorization validation and evidence review also completed on 2026-09-09. The later Phase 4/5 validation deployment was then destroyed and bounded cleanup verification completed; see the [Phase 7 teardown validation](evidence/phase-7-teardown-validation.md).

Phase 6 broader CI/CD security controls remain future work.

Return to the [project README](../README.md) for the project overview and current status.
