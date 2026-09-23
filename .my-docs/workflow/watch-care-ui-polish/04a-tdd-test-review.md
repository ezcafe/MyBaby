# TDD test-case review: watch-care-ui-polish

**Result:** clean
**Round:** 1
**Updated:** 2026-09-23

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1 | real | bottle stops running breast → idle | planned |
| 1 | real | diaper stops breast → idle | planned |
| 1 | real | breast L↔R switch clears other | planned |
| 1 | real | self-stop → done | planned |
| 1 | edge | pump keeps nap/breast | existing + keep |
| 1 | real | bottle clears open nap | existing (update if phase asserted) |
| 1 | real | sleep/breast start clears nap → idle | add if missing |
| 2 | real | running title has no “Tap to stop” | planned if strings extracted |
| 3 | edge | visibleRowCount == 3 constant | optional |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Major | 1 | Sleep start while breast running → breast idle | `modelNapStartStopsBreastToIdle` |
| Enhancement | 2 | Title helper | `TimedChipSide.runningTitle` / chip title builder |

## Real scenarios checked

- Happy path: log bottle/diaper while breast+nap active
- User-visible failures: N/A offline sample
- Empty / loading / permission: N/A

## Edge / boundary

- Pump amount while breast+nap: leave both
- Dual breast: only one running after switch
- Self-stop still Done flash

## Fix ask (if needs more tests)

1. Add `modelNapStartStopsBreastToIdle` in Task 1 (Build).
2. Prefer extractable running title for Task 2 assert.

## Round notes

- main-thread fallback — tdd-review — usage limit
- Result **clean** with Build-time adds listed (not blocking Gate B)
