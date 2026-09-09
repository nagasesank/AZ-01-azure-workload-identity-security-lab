# Documentation Guide

This directory is the navigation hub for AZ-01 design records, implementation records, validation evidence, and future remediation documentation.

## Documentation Areas

- [Architecture](architecture/README.md): system boundaries and security decisions.
- [Attack path](attack-path/README.md): controlled lab-test scope and sequence.
- [Threat model](threat-model/README.md): assets, threats, and planned controls.
- [Implementation](implementation/README.md): verified implementation and remediation records.
- [Evidence](evidence/README.md): verified validation records and sanitized screenshots.

## Documentation Lifecycle

```text
Design -> implementation -> validation -> evidence -> remediation -> revalidation
```

Phase 3 evidence is the vulnerable, pre-remediation baseline. Phase 4 runtime evidence remains separate so the historical attack results are not confused with remediation results.

Phase 4 OIDC authentication and intended synthetic-blob metadata read validation completed successfully on 2026-09-09. Phase 5 remains future post-remediation authorization and re-attack validation work.

Return to the [project README](../README.md) for the project overview and current status.
