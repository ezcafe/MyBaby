# Light repo skim: watch-fail-status-settings

**Result:** done  
**Updated:** 2026-09-26  
**Size:** ≤ ~40 lines  
**Note:** main-thread fallback — usage limit

## Project shape (1–3 sentences)

watchOS SwiftUI care app: page TabView (Feed→Sleep→Diaper→Pump→Last care), sample/live modes, live fails set muted footer `statusFail`. Connect is gear/`AuthConnectView`; token Keychain via `BabyAPITokenStore.clear()` already exists. No Settings page yet; fail is not shown on trigger chips.

## Related existing UI / screens

| Path | What it does | Reuse? |
|------|--------------|--------|
| `CareControls.swift` | Chips, ml grid, `CareFooterSlot` | Add fail chrome on chips |
| `CarePages.swift` / `BabyHomeView.swift` | Pages + TabView | Add Settings page last |
| `AuthConnectView.swift` | Connect / sample | Reuse host display; logout exit |
| `ContentView.swift` | Auth gate + gear → connect | Wire logout → connect |

## Related APIs / data

| Path | Notes |
|------|-------|
| `BabyHomeStatusModel.applyLiveFailure` | Maps errors → `statusFail` / `needsReconnect` |
| `BabyAPITokenStore.clear()` | Logout already possible at store layer |
| `BabyHomePage` | Add `.settings`; update `shouldMount` / deep link |

## Hard constraints

1. One footer slot priority: recovery → fail → tip (keep).
2. Teal/neutral `BabyTokens`; no purple marketing look.
3. Neighbor-only TabView mount (`shouldMount` ±1).
4. No new GraphQL/API routes this pass.

## Risks if ignored

- Fail only in footer → still miss errors.
- Settings without logout → token stuck.
- Extra page without updating `shouldMount` / tests → mount bugs.

## Enough for UI concept / Analyze?

yes
