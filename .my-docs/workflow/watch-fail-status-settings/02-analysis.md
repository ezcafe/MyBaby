# Analysis: watch-fail-status-settings

**Result:** done  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit after Analyze Task retry

## Overall — What / Why / How

1. **What is this?** Watch UI so live send failures show on the trigger chip; Settings is last TabView page with Log out; after logout user must Connect (guide at bottom of connect).
2. **Why do we need this?** Footer-only `statusFail` is easy to miss; gear-only settings hides logout; after logout care must not stay open without credentials.
3. **How to do this?** Model tracks which control failed → chip fail chrome; add `BabyHomePage.settings` + Settings view + `logout()` clearing Keychain; AuthConnect guide at bottom; remove sample shortcut on connect (Gate A2). Other ways: view-local error state (weaker); Alert (rejected). Best practice: reuse `applyLiveFailure` + `CareFooterSlot`; match approved HTML.

## Deep dive by piece

### A — Chip fail status

| | |
|--|--|
| **What** | Failed live quick-care marks the control that sent the request |
| **Why** | Attention is on the chip just tapped |
| **How** | Track `lastFailedControl` (enum: timed side / bottle ml / pump ml / diaper). On `applyLiveFailure` after send, set it; clear on success or new tap. Extend chip phases or overlay fail style. **Alt:** only footer — rejected by Gate A2. **Best:** model owns state like `statusFail`. |

### B — Settings page + logout

| | |
|--|--|
| **What** | Last page: host + Log out |
| **Why** | Discoverable exit from live |
| **How** | `BabyHomePage.settings`; `SettingsPage`; `logout()` → `tokenStore.clear()`, nil client, `isConnected=false`. **Alt:** Settings sheet — rejected (user asked last page). |

### C — Connect gate + guide

| | |
|--|--|
| **What** | After logout, connect only; quick guide at bottom |
| **Why** | Must re-auth; teach pairing steps |
| **How** | Existing `AuthGate` + ContentView; add guide below Save & connect; drop Continue with sample on this screen per A2. |

## Reusable patterns

- `applyLiveFailure` / `statusFail` / `needsReconnect`
- `BabyAPITokenStore.clear()`
- `CareFooterResolver` priority
- `BabyHomePage.shouldMount` ±1
- Auth gate in `ContentView`

## System shape candidates

1. **Model-owned fail control + Settings page** (recommended)
2. View-local `@State` errors — harder to test; drift from footer

## Has API / Has DB

- **Has API:** no  
- **Has DB:** no  

## Enough to design?

yes — Gate A2 HTML is source of truth for Build.
