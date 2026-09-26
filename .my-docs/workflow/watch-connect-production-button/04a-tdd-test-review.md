# TDD test-case review: watch-connect-production-button

**Result:** ok

**Round:** 2  
**Note:** main-thread — after Decision 1 URL field

## Planned test cases

| # | Case | Task | Enough? |
|---|------|------|---------|
| 1 | Resolver local → `.local` | 1 | yes |
| 2 | Resolver production → `.production` | 1 | yes |
| 3 | Resolver empty/other → `.none` | 1 | yes |
| 4 | Existing normalize/validate URL tests still apply to primary field | 2 | yes |

## Gaps

None blocking. UI field visibility is Build acceptance + manual Watch check.

## Fix ask for Build

None — Gate B again after Decision 1 change.

## Round notes

- Round 2: ok with URL-field scope.
