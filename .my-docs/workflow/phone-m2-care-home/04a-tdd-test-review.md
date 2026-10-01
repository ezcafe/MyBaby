# TDD test-case review: phone-m2-care-home

## Result

**ok**

## Planned cases vs gaps

| Task | Planned tests | Review |
|------|---------------|--------|
| 1 Share model compile | Compile smoke + Watch tests still green | ok — add note: no new unit unless iOS-specific init bug |
| 2 Session → model wire | Fake client/store: live load vs offline no GraphQL | ok — required before UI |
| 3 TabView shell | Page mapping unit; UITest optional | ok — allow skip UITest if no Phone UITest target |
| 4 Fail/retry + diaper | Retry same id; offline fail fake | ok — reuse Watch tests; add Phone-facing if helpers move |
| 5 README | N/A | ok |

## Findings

| Severity | Finding | Action |
|----------|---------|--------|
| Enhancement | Prefer one new `PhoneCareWiringTests` file for Task 2 | Build may add under Watch AppTests or new Phone tests |
| Nit | UITest optional | Keep skip allowed |

## Fix ask for tasks

None — cases are concrete enough for Build TDD.

## Round notes

- main-thread fallback — 04a — usage limit
