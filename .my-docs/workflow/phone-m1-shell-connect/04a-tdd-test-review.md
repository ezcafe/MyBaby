# TDD test-case review: phone-m1-shell-connect

**Result:** ok  
**Round:** 1  
**Updated:** 2026-09-30  
**Note:** main-thread — usage limit

## Planned cases (from 04-tasks)

| Area | Cases | Verdict |
|------|-------|---------|
| Session restore | Offline restore; live+token restore; no mode → Connect | ok |
| Offline fail | Store init throws → not connected + error | ok |
| Leave | Offline leave keeps events (fake assert not cleared); live leave clears token | ok |
| Pair | Redeem success/fail | ok |
| Connect helpers | Preset visibility Offline vs Cloud | ok if extracted |
| Target/entitlements | Container id constant vs entitlements string | ok light |

## Gaps

- None Critical. Optional UI test for Connect — Enhancement only.

## Fix ask

none

**04a ok** — ready for Gate B.
