# TDD test-case review: essay-recs-align

**Updated:** 2026-09-24  
**Mode:** simple · main-thread fallback (usage limit)

## Result

**ok** — planned tests cover remap, breast≠bottle, sleep blends, Watch stage/snaps, EN/VI tips, cross-app fixtures.

## Coverage vs tasks

| Task | Planned failing tests | Adequacy |
|------|----------------------|----------|
| 1 Feed bands | days → ml/feeds; no 5–15; breast≠bottle; toddler chip note | ok |
| 2 Sleep | five essay totals; awake ~45–60 | ok |
| 3 Footers/guide | stage keys; Size/pump asserts; guide checklist | ok |
| 4 Watch CareGuide | stage cuts; snaps; history-first | ok |
| 5 Watch i18n | EN + VI tip resolver | ok |
| 6 Cross-app | shared number literals | ok (light) |

## Gaps / Fix ask

(none blocking)

### Enhancement (non-blocking)
- Prefer one shared expected-triples constant comment in both test files (Task 6).

## Gate B ready?

**Yes** — design + tasks + planned tests OK for human Gate B.
