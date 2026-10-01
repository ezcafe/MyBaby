# TDD test-case review: phone-security-perf

**Result:** ok  
**Round:** 1  
**Updated:** 2026-10-01  

## Planned cases vs gaps

| Task | Planned tests | Adequacy |
|------|---------------|----------|
| 1 URL policy | loopback http / reject cleartext host / https OK; paste/pair still works | ok |
| 2 GQL sanitize | crafted message must not appear in statusFail; auth cases preserved | ok |
| 3 Offline limit | limit 80 asserted; desiredKeys / round-trip | ok — prefer spy on store `fetchRecent(limit:)` |
| 4 Widget coalesce | injectable coalescer: N schedules → 1 fire | ok |
| 5 Smoke | build + unit suite | ok |

## Fix ask

None.

## Notes

- Red-first order: Task 1→4 units before production edits; Task 5 last.
- Use existing `MyBaby Watch AppTests` patterns (`InMemoryBabyAPITokenStore`, fake stores).
- Ready for Gate B (blocking).
