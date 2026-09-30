# TDD test-case review: offline-icloud-mode

**Result:** ok  
**Updated:** 2026-09-29  
**Note:** main-thread fallback — usage limit

## Planned / existing test cases reviewed

| Area | From tasks | Adequate? |
|------|------------|-----------|
| Connect Offline/Cloud defaults + visibility | Task 1 | yes |
| useOffline / restore / logout / auth gate | Task 2 | yes |
| Projector + fake store | Task 3 | yes |
| CloudKit impl | Task 4 | yes — units on errors/mapping; CK integration manual |
| Model Offline chip writes | Task 5 | yes |
| Existing live GraphQL / Local resolver tests | repo | Keep; update any Local-default assumptions that break |

## Gaps (must add before or during Build)

| Gap | Add to |
|-----|--------|
| Cloud tap sets URL to `localPreset` (not empty) — regresses prior “clear URL” behavior | Task 1 tests |
| Resolver/UI: no Local chip; Offline default | Task 1 |
| Offline connected without token | Task 2 |

## Real scenarios checked

- First launch → Offline default → Start → log diaper → kill → restore Offline → event still in fake/CK store
- Cloud → URL shows 127.0.0.1:3000 → pairing → live (existing path)
- iCloud error on Start Offline → user-visible failure

## Edge scenarios checked

- Logout Offline does not wipe CloudKit
- Live mode still GraphQL-only
- App Group still has no token keys

## Fix ask for Build / tasks

None blocking — optional: add explicit unit “Cloud default URL equals localPreset” in Task 1 (already in Acceptance).

## E2E

Watch UI tests optional; prefer unit + manual Connect/Offline smoke. No new web e2e (Has API no).

## Round notes

- Result **ok** — ready for Gate B (human): design + tasks + tests; confirm Build matches HTML; skim System design / Design patterns.
