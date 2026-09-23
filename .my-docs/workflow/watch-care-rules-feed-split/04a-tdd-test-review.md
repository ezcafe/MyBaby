# TDD test-case review: watch-care-rules-feed-split

**Result:** clean
**Round:** 1
**Updated:** 2026-09-23

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1 | real | Open nap + breast → nap ends | yes |
| 1 | real | Open nap + bottle → nap ends | yes |
| 1 | real | Open nap + diaper → nap ends | yes |
| 1 | real | Open nap + pump → nap stays | yes |
| 1 | real | Bottle while breast running → breast stops | yes |
| 1 | edge | Chip builder history first, limit 2 | yes |
| 1 | edge | Empty history + no-birth snaps → [60, 90] | yes |
| 2 | real | Deep link bottle / feed / fallback | yes |
| 3 | real | Model selectBottle clears open nap | yes |
| existing | edge | ageTitle days/months | yes (helper kept) |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Enhancement | 1 | Breast switch L↔R while nap open | Assert nap ends once on first breast start |
| Enhancement | 1 | Pump amount select does not clear breast | Unit on side-effects |

## Real scenarios checked

- Happy path: Feed/Bottle/Diaper end nap; Pump does not
- User-visible failures: n/a local sample
- Empty / loading / permission: empty recent → snaps

## Edge scenarios checked

- Boundaries: chip limit 2; duplicate history skipped
- Concurrency: n/a local
- Offline: n/a

## Fix ask for Build

1. Include Enhancement cases above in Task 1 if cheap
2. Update deep-link fallback expectation from `.feedBottle` → `.feed`

## Round notes

- Clean enough for Gate B; Enhancements optional during Build
- Main-thread fallback — usage limit
