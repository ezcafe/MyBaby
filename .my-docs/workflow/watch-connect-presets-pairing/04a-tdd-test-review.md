# TDD test-case review: watch-connect-presets-pairing

**Result:** needs more tests (folded into tasks below)  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## Coverage vs tasks

| Task | Real scenarios covered? | Important edges covered? | Gap |
|------|-------------------------|--------------------------|-----|
| 1 Schema | yes | FK / indexes | ok |
| 2 Service | yes | expired, consumed, invalidate-prior, auto-revoke | add **alphabet/normalize** (trim, case) |
| 3 Routes | yes | unauth, same-origin, rate limit, error codes | add **bounded JSON body** size (mirror tokens) |
| 4 Web UI | yes | Generate displays code | add **expiry visible** assert |
| 5 Watch client | yes | success + 4xx | add **retry-until-consumed** does not double-save on second 200 impossible — assert client stops after success |
| 6 Watch UI | partial | invalid banner | add unit for **advanced paste still works** vs code path |
| 7 Docs | optional | — | ok |

## Fix ask (fold into `04-tasks.md`)

1. Task 2: test code trim / case folding policy (lock: trim whitespace; uppercase for compare).
2. Task 3: test oversized body rejected (readJsonBounded pattern).
3. Task 4: assert expiry shown after Generate.
4. Task 5–6: assert paste/advanced path still saves Keychain without calling redeem.

## Strong test names (suggested)

- `mintInvalidatesPriorUnconsumedCode`
- `redeemExpiredReturnsEXPIRED`
- `redeemSecondTimeReturnsCONSUMED`
- `redeemRevokesPriorAppleWatchToken`
- `mintUnauthorizedWithoutSession`
- `mintRejectedCrossOrigin`
- `redeemRateLimited`
- `watchPairClientMapsInvalidCode`
- `authConnectAdvancedPasteSkipsRedeem`

## Result after fold

Parent folds Fix ask into tasks → treat as **ready for Gate B** (no second TDD review required unless Gate B rejects).
