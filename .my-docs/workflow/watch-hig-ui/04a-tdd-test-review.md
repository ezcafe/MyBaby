# TDD test-case review: watch-hig-ui

**Result:** clean  
**Round:** 1  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## Coverage vs tasks

| Task | Real scenarios | Edge scenarios | Enough? |
|------|----------------|----------------|---------|
| 1 Vertical + bg | Distinct bg for feed vs sleep; page order 5 | Overdue feed tint distinct | yes |
| 2 Bottle/Amount sheets | Model still receives bottle/pump ml selects | Custom still opens picker | yes (model-level) |
| 3 Loading / Retry | isStatusLoading toggle | Fail identity labels unchanged | yes |
| 4 Last care hero | Hero for open nap / next feed samples | Overdue cases | yes |
| 5 App Group + widgets | Round-trip DTO; empty → sample; rect secondary; **no token keys** | Missing suite fallback | yes |
| 6 Connect | Guide behind disclosure (manual/HTML); Advanced default hidden | — | yes |

## Suggested test names (Build)

1. `carePageBackgroundDistinguishesFeedAndSleep`
2. `carePageBackgroundMarksOverdueFeed`
3. `statusStoreRoundTripWithSuite`
4. `statusStoreEmptyFallsBackForWidgets`
5. `statusStoreDTOExcludesTokenKeys`
6. `lastCareHeroCopyForOpenNapAndNextFeed`
7. `rectangularComplicationSecondaryLine`
8. Existing: page order, bottle select, isStatusLoading, fail identity — keep green

## Gaps / Fix ask

(none Critical/Major — token-key assert folded into Task 5)

## Gate B note

Approve Design Option 1 + tasks + these tests. Confirm Build will match approved HTML ui-refs (text only; do not re-show). Skim System design + Design patterns teach sections — OK.
