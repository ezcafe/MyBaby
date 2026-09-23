# TDD test-case review: watch-care-button-rules

**Result:** clean

**Round:** 2

## Planned / existing test cases reviewed

| Task | Scenario | Covered? |
|------|----------|----------|
| 1–2 | Nap self-stop; sleep flags; flash-only log; pump independence | yes |
| 1–3 | Page order + pump-amount query; chip limit 3 | yes |
| 1–3 | Pump Both exclusivity | yes |
| 4 | Last care sample copy/icons (stable strings) | yes |

## Gaps

None Critical/Major.

## Fix ask for Build

1. Add red tests listed in Task 1 before production edits.
2. Optionally assert Last care sample sentences/icons from Task 4.

## Round notes

- Round 2 after UI scope expand.
- Main-thread fallback — usage limit.
