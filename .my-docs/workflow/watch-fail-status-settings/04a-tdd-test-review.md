# TDD test-case review: watch-fail-status-settings

**Result:** ok  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## Planned cases vs tasks

| # | Area | Covered by tasks? | Notes |
|---|------|-------------------|-------|
| 1 | Page order + settings query + shouldMount | Task 1, 4 | yes |
| 2 | Fail control set/clear on live send | Task 1, 2 | yes |
| 3 | Logout clears token + disconnect | Task 1, 2, 5 | yes |
| 4 | Footer priority unchanged | Task 1 | yes |
| 5 | Chip fail chrome | Task 3 | unit helpers OK |
| 6 | Connect gate after logout | Task 5 | yes |
| 7 | Guide at bottom / no sample | Task 5 | string/manual OK |

## Gaps

| Severity | Gap | Ask |
|----------|-----|-----|
| Nit | No e2e Watch UI automation in repo | Manual Gate C glance — OK |

## Fix ask for tasks

None — Result **ok**.

## Gate B ready?

yes — approve design + tasks + tests; Build must match HTML ui-refs.
