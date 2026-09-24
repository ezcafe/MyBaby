# TDD test-case review: watch-api-base-url

**Result:** clean
**Round:** 1
**Updated:** 2026-09-24

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1 | real | normalize strip slash; graphqlURL append path once | yes |
| 1 | edge | empty / relative / non-http(s) reject | yes |
| 2 | real | Keychain round-trip + clear | yes |
| 3 | real | URL + Authorization + body keys via mock session | yes |
| 3 | edge | GraphQL errors → typed failure | yes |
| 4 | real | Fixture status → snapshot key fields | yes |
| 4 | edge | Missing fields safe empty; day window bounds | yes |
| 5 | real | bypass false + not connected → connect (if extractable) | partial |
| 6 | real | load status updates snapshot | yes |
| 6 | real | breast start = 0 calls; stop = BREAST + breastRunning | yes |
| 6 | edge | clientRequestId retry same id | yes |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| Enhancement | 3 | Missing token → no Authorization header (or fail fast) | Assert header absent / connect blocked |
| Enhancement | 6 | 401 maps to reconnect/statusFail | Stub returns UNAUTHORIZED → statusFail set |

## Real scenarios checked

- Happy path: normalize → client POST → map status → mutation on log
- User-visible failures: GraphQL errors; invalid URL
- Empty / loading / permission: missing fields; sample without token

## Edge scenarios checked

- Boundaries / invalid input: bad URL schemes
- Concurrency / double-submit / idempotency: clientRequestId retry
- Offline / partial data: missing status fields

## Fix ask for Build

Concrete tests to add or strengthen during Build (Enhancements OK to include):

1. Client: missing token behavior (no secret leak; clear failure).
2. Model: UNAUTHORIZED → statusFail / reconnect signal.

## Round notes

- main-thread fallback — tdd-review — usage limit
- No Critical/Major gaps; planned Task 1–6 TDD covers Option 2 MVP
