# TDD test-case review: watch-baby-care-home

**Result:** clean
**Round:** 1
**Updated:** 2026-09-23

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1 | real | primarySignal returns nap when open | yes |
| 1 | real | overdue beats next-feed | yes |
| 1 | edge | age title days vs months | yes |
| 2 | real | footer recovery over tip | yes |
| 2 | real | timed chip idle→running→done→idle | yes |
| 3 | real | URL page=sleep → .sleep | yes |
| 3 | edge | unknown page fallback | yes |
| 4 | real | timeline nap tick / next due | yes |
| 4 | real | deep link URL matches page ids | yes |
| 5 | — | README manual | yes (N/A automated) |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Nit | 2 | Feed+Bottle footer owner when both pending | Assert breast pending wins over bottle tip (optional Build add) |
| Nit | 1 | Diaper Poop label maps to dirty in model enum | Add when API mapping helper lands |

## Real scenarios checked

- Happy path: signal priority, chip states, deep links, widget timeline
- User-visible failures: footer recovery over tip
- Empty / loading / permission: auth stub out of unit scope; sample empty last-care via snapshot fields in Build previews

## Edge scenarios checked

- Boundaries: unknown deep-link page
- Concurrency / double-submit: deferred (UI-first; later clientRequestId)
- Offline: N/A sample

## Fix ask for Build

Concrete tests to add or strengthen:

1. (none blocking — Result clean)
2. Optional Nit: footer owner when breast pending + bottle tip on page 1

## Round notes

- Main-thread fallback — usage limit on TDD review Task.
- Design-review clean; planned tests cover Tasks 1–4 critical paths.
