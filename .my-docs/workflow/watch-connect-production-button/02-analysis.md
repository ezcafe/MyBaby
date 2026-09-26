# Analysis: watch-connect-production-button

**Mode:** simple · **Note:** main-thread fallback — usage limit after Analyze Task retry

## Overall — What / Why / How

1. **What is this?** Fix Watch Connect **Production** so choosing it actually selects a production pairing host (and the host line / redeem path reflect that).
2. **Why do we need this?** Today Production and Local resolve to the same origin by default, so the Production button looks dead and redeem may hit the wrong host for a real deploy.
3. **How to do this?** Stop treating unset Production as Local loopback; drive Production from `BabyProductionPairingOrigin` (plist) with clear UI feedback when unset; keep Local = `http://127.0.0.1:3000`. Other ways below. Best practice: config-over-code for deploy origin; never silently alias Production → Local.

## Deep dive by piece

### A — Root cause (config alias)

| | |
|--|--|
| **What** | `BabyAPIConfig.productionPairingOrigin` falls back to `http://127.0.0.1:3000` when plist missing; `productionPreset` aliases that. `Config/WatchApp-Info.plist` has **no** `BabyProductionPairingOrigin`. AuthConnectView Production button only assigns `baseURL = productionPreset`. |
| **Why** | Same URL as Local → `displayHost` unchanged after Local → feels broken; redeem bootstrap can stay on loopback. |
| **How** | Remove silent loopback fallback for Production (or treat unset as empty + error). Set plist for real HTTPS. Tests: Local ≠ Production when configured; unset Production fails validate / shows error. **Alt:** keep alias for sim — rejected (user reports Production broken). **Best:** plist-required Production; Local stays loopback. |

### B — Connect UI feedback

| | |
|--|--|
| **What** | Presets are plain Buttons; no selected chrome; host caption is only feedback. |
| **Why** | When URLs collide, zero visible change on tap. |
| **How** | After config fix, host caption differs. Optional: light selected style — only if still needed. **Alt:** selected chips only without URL fix — insufficient. |

### C — Redeem path

| | |
|--|--|
| **What** | `saveAndConnectLive` uses `normalize(baseURL) ?? productionPairingOrigin`. |
| **Why** | Must use the Production origin the user picked. |
| **How** | Keep wiring; ensure Production tap writes distinct valid origin into `baseURL` before redeem. No API change. |

## Decision 1: how Production origin is supplied

### Option 1 — Plist-required (recommended)

- **What it is:** Production = normalized `BabyProductionPairingOrigin` only. No loopback fallback. Missing/invalid → Production tap shows error; host stays unset or prior.
- **Example:** Plist `https://app.example.com` → Production sets that; Local stays `127.0.0.1:3000`.
- **Pros:** Matches deploy docs; Local ≠ Production; no wrong-host redeem.
- **Cons:** Needs a real origin value from the user / project before Production works on device.

### Option 2 — Bake a hard-coded HTTPS default in Swift

- **What it is:** Change Swift default string to a known deploy URL.
- **Example:** `return "https://….vercel.app"`.
- **Pros:** Works without plist edit once known.
- **Cons:** Wrong if host changes; not in repo today — would be guessing.

### Option 3 — UI selection only (keep same URL default)

- **What it is:** Highlight Production vs Local; keep identical loopback default.
- **Example:** Selected tint on Production; host still `127.0.0.1:3000`.
- **Pros:** Cheap visual fix.
- **Cons:** Does not fix real Production pairing — **reject** as sole fix.

### Recommendation

**Pick Option 1** for deploy hosts when a URL is known.

### Settled (user 2026-09-26)

1. **Decision 1:** Always-visible **URL input field** for user input (presets fill it).
2. Keep **active/selected** Local vs Production chrome.
3. Production HTTPS plist default remains deferred.

## Reusable patterns

- `BabyAPIConfig.normalize` / `validate` / `saveBaseURL`
- AuthConnectView preset buttons + `displayHost`
- Info.plist keys on Watch target (`Config/WatchApp-Info.plist`)
- Unit tests in `MyBaby_Watch_AppTests` (`BabyAPIConfig` suite)

## System shape candidates

- Client-only config + Connect UI — no new server boundary
- Has API: **no** · Has DB: **no**

## Reference files

- `BabyCareShared/BabyAPIConfig.swift`
- `MyBaby Watch App/Views/AuthConnectView.swift`
- `Config/WatchApp-Info.plist`
- `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift` (preset tests)
- `README.md` (Production origin note)

## Blocking questions

None for this run — user locked active-state UX. Production HTTPS origin deferred.

## Clarity check

Yes — clear enough to design: active/selected Local vs Production on Connect.

## Has API / Has DB

- **Has API:** no
- **Has DB:** no
