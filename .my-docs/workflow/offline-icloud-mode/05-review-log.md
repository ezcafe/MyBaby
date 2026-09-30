# Code review log: offline-icloud-mode

## Adversarial test review

**Result:** ok  
**Updated:** 2026-09-29  
**Note:** main-thread (usage limit)

Checks: Offline default + Cloud URL default units; projector last-*; useOffline without token; logout keeps store events; offline bottle append; existing live path still covered.

No Critical/Major gaps vs 04a.

## Quality

**Result:** ok  

- Connect matches approved HTML (Offline|Cloud; Start Offline; Cloud URL default).
- Offline store protocol + CloudKit impl + fake for tests.
- Secrets not in CloudKit/App Group.
- Minor: CloudKit Start Offline requires iCloud account (documented).

## Merged SPM

**SPM plan:** db+security

### DB (`05-lens-db` inline)

- CareEvent schema matches design; schemaVersion present; fetch by `at` DESC.
- No migration yet beyond schemaVersion field — OK for v1.
- Result: ok

### Security

- Token/pairing not written to CareEvent or App Group.
- Offline uses private CloudKit.
- Result: ok

### Fix ask

None.

## Round notes

- Smoke-pass before review. Draft ready for full test confirmation then Gate C.
