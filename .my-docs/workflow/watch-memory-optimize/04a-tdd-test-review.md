# TDD test-case review: watch-memory-optimize

**Result:** clean
**Round:** 1
**Updated:** 2026-09-23

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1–2 | real | Second done-flash schedule cancels prior Task | yes (planned) |
| 1–3 | real / edge | `shouldTick` true only when running + page selected + scene active | yes (planned) |
| 1–3 | edge | running + off-page → no tick; idle → no tick | yes (planned) |
| 4 | real | Widget timeline nextUpdate nap/feed (existing) | yes |
| 2 | real | Done flash still clears after ~2s (behavior) | partial — keep existing care tests; cancel focus is Task 1 |
| 5 | real | Memory re-measure | manual (lite OK) |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Enhancement | 1 | Assert cancel without sleeping 2s | After second `schedule*`, first task `isCancelled == true` |

## Real scenarios checked

- Happy path: running chip ticks on selected active page; done flash clears
- User-visible failures: N/A (local UI)
- Empty / loading / permission: N/A

## Edge scenarios checked

- Boundaries: ticks off when background or wrong page
- Concurrency: stacked done-flash schedules
- Offline / race: cancel-before-replace

## Fix ask for Build

1. Task 1: prefer cancel-token assertion (no full 2s sleep) when implementing.
2. Keep existing care-matrix / timeline tests green (regression lock).

## Round notes

- Main-thread fallback — tdd-review — usage limit
- No Critical/Major gaps; Enhancement is implementation hint for Build
- Result **clean** for Gate B (Enhancement does not block; Build must honor Fix ask #1)
