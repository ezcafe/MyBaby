# TDD test-case review: phone-hig-ui

**Result:** ok  
**Round:** 1  
**Updated:** 2026-10-01  
**Note:** main-thread fallback — usage limit

## Planned cases vs tasks

| Task | Planned tests | Adequate? |
|------|---------------|-----------|
| 1 Connect | Unit on helpers if extracted; manual Offline/Cloud | yes — pure preset logic already exists; no forced new helper |
| 2 Metrics | Unit on token helpers if pure; else simulator note | yes — prefer pure helper tests when added |
| 3 Status + Leave | Manual / XCTest if Settings host exists | yes |
| 4 Smoke | xcodebuild Phone + Watch | yes — required for shared edits |

## Findings

| Severity | Finding | Suggestion |
|----------|---------|------------|
| Enhancement | Task 2 could name one concrete XCTest for iOS vs watchOS font helper | Optional: add `BabyTokensPhoneMetricsTests` if helpers are static pure |

## Fix ask

None required for Gate B — Result **ok**. Optional Enhancement can land in Build.

## Ready for Gate B?

**Yes** — design + tasks + test plan sufficient.
