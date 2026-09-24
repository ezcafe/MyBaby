# TDD test-case review: watch-feed-pump-merge

**Result:** clean
**Round:** 1
**Updated:** 2026-09-24

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1 | real | Five-page order raw values | yes (planned update) |
| 1 | real | `fromQuery("bottle")` → `.feed` | yes |
| 1 | real | `fromQuery("pump-amount")` → `.pump` | yes |
| 1 | edge | `shouldMount` neighbors after remumber | yes |
| 2 | real | `selectBottle` / `selectPump` side effects unchanged | yes (keep existing) |
| 3 | real | Primary-signal deep links still `.feed`/`.sleep`/… | yes |
| 2 | edge | Scroll vs swipe | no — manual / smoke |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Enhancement | 1 | Explicit `breast` still maps to feed | Keep existing breast alias test if present |
| Enhancement | 2 | UI composition | No SwiftUI unit needed; model tests suffice |

## Real scenarios checked

- Happy path: deep link aliases; five-page strip; bottle/pump ml still call model
- User-visible failures: N/A for this UI merge
- Edge: mount ±1 after rawValue change

## Fix ask for tasks (if any)

1. None — planned TDD updates are enough for Gate B

## Round notes

- Result **clean** — proceed to Gate B.
- Main-thread fallback — tdd-review — usage limit.
