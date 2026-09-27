# TDD test-case review: watch-complication-timer-status

**Result:** ok  
**Round:** 1  
**Updated:** 2026-09-27

## Planned / existing test cases reviewed

| Task | Scenario type | Test case | Covered? |
|------|---------------|-----------|----------|
| 1 | real | Running nap beats overdue / last care | yes |
| 1 | real | Running breast when no nap | yes |
| 1 | real | Idle picks latest care `at` | yes |
| 1 | real | In-range teal / out-of-range red | yes |
| 1 | real | Deep link page matches kind | yes |
| 2 | real | Parse ISO `at`; stage → interval | yes |
| 3 | real | DTO round-trip; no token keys | yes |
| 3 | real | Breast start → store shows runningStartedAt | yes |
| 4 | real | Timeline policy still valid after DTO change | yes (adjust) |
| 5 | real | Sample helpers for three Gate A2 states | yes |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Major | 1 | Pump running when no nap/breast | Add case in Task 1 matrix |
| Major | 3 | Pump start/stop also persists (parity with breast) | Assert persist after pump toggle |
| Enhancement | 1 | Simultaneous nap+breast → nap wins | Explicit priority fixture |
| Enhancement | 4 | Color + label both present when red (a11y) | Assert kind label non-empty with danger color |

## Real scenarios checked

- Happy: start timer → face live; stop → last care color
- Empty store → sample fallback (Task 3)
- Deep link pages for nap/feed/pump

## Edge scenarios checked

- Priority nap > breast > pump
- Overdue boundary color flip
- forbiddenKeys on encode

## Fix ask for Build / tasks

1. Add **pump running** unit case to Task 1.
2. Task 3 tests: **pump** start/stop persist, not only breast.
3. Optional: nap-beats-breast priority fixture; red state keeps kind label.

## E2E

Watch XCUITest face complications are heavy — **unit coverage is enough** for this run (full profile can keep manual face check in Gate C test plan). No new e2e Task required.

## Round notes

- Main-thread fallback — tdd-review — usage limit after Task retry.
- Result **ok** for Gate B after Fix ask folded into Build (parent may patch 04-tasks briefly).
