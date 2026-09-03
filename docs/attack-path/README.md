# Controlled Attack Path

AZ-01 attack validation is a controlled security test, not general offensive tooling. Tests use project-owned resources, known targets, and synthetic data only; they do not enumerate or target arbitrary subscription resources.

- [Phase 1 controlled attack plan](phase-1-attack-plan.md)
- [Phase 3 validation evidence](../evidence/phase-3.md)

## Phase 3 Sequence

- AT-01 verifies vulnerable credential authentication.
- AT-02 verifies workload resource-group enumeration.
- AT-03 performs a harmless tag mutation and verifies restoration.
- AT-04 verifies synthetic blob access.
- AT-05 verifies denial against the project-owned negative-control canary.

All actions are bounded to the lab. AT-03 restores the original tag state, and AT-05 is a negative-control test rather than an attempt to discover unrelated resources.

Return to the [documentation guide](../README.md).
