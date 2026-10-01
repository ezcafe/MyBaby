# Design: phone-m1-shell-connect

**Mode:** full  
**Has API:** no · **Has DB:** yes  
**Updated:** 2026-09-30  
**Grill:** frontier-empty (02b)

## Decision 1: Phone application shape

### Option 1 — Real iOS Application + thin session (recommended)

- **What it is:** Replace/repurpose “MyBaby Phone App” into `com.apple.product-type.application` with SwiftUI `@main` App; thin session model for Connect/Offline/Cloud; park App Intents appex.
- **Example:** `MyBabyPhoneApp: App` → `ContentView` connect gate → `PhoneConnectView` / placeholder home + Settings sheet.
- **Pros:** Matches Gate A; installable app; M2 plugs into same shell.
- **Cons:** Xcode target surgery; entitlements setup on new app id.

### Option 2 — Stretch Watch model + keep appex for intents in same PR

- **What it is:** Move full `BabyHomeStatusModel` to shared and ship intents extension alongside.
- **Example:** Phone embeds Watch care model with chips hidden.
- **Pros:** Less M2 model work later.
- **Cons:** Heavy M1; risk of half-broken care UI; blocks on intents.

### Recommendation

**Pick Option 1** — grill Q1/Q2/Q3; user-first Connect-only M1.

## Chosen design (locks)

### Target

1. **iOS Application** target for Phone (not ExtensionKit). Bundle id keep `vn.in4.MyBaby-Phone-App` unless signing forces rename.
2. Link **BabyCareShared** (same as Watch).
3. Entitlements file (new `Config/PhoneApp.entitlements` or equivalent): `iCloud.vn.in4.MyBaby` + CloudKit; `group.vn.in4.MyBaby`.
4. App Intents appex: **not** required for M1 launch scheme.

### Connect (Watch parity)

1. Chips **Offline | Cloud** (Offline left + **default**).
2. Offline: hide URL + pairing; hint iCloud; **Start Offline** → session `useOffline()`; on iCloud failure keep disconnected + error.
3. Cloud: URL default `BabyAPIConfig.localPreset` / `http://127.0.0.1:3000`; pairing code; **Save & connect**; **Advanced: paste URL & token** (secondary).
4. No Local chip.

### Session

- Thin `@Observable` `PhoneSessionModel` (Phone target or shared connect module): `isConnected`, `mode`, offline store ref, live client/token hooks, `leave()` / reconnect.
- Cold start: `CareDataModeStore.load()` → restore Offline (no token) or live (if token) else Connect.
- Mode flag: **Phone-local** UserDefaults (grill Q5); CloudKit holds care events for cross-device.

### Post-connect shell

- Placeholder home: short copy that care logging comes next (M2); gear → Settings sheet (mode, iCloud status, Leave).
- Leave Offline/Cloud: clear session → Connect; **do not** wipe CloudKit events; live leave clears token from Keychain like Watch.

### Widgets

- Entitlements only for App Group readiness; **no** widget UI work in M1.

## System design

### Overview

- Phone App (iOS) owns UI shell + thin session.
- Connect routes: Offline → `OfflineCareStoring` / `CloudKitOfflineCareStore` (private DB `iCloud.vn.in4.MyBaby`); Cloud → `WatchPairClient` redeem + `BabyAPITokenStore` + live GraphQL client ready for M2 (M1 may only verify token save / optional ping).
- Snapshot/App Group write optional in M1 (empty or last projection) — full widget path is M3.
- Boundary: **no new my-apps HTTP**; no CloudKit schema change; Watch unchanged except shared-safe refactors if required.

### Concept 1 — Mode as routing

`mode` selects Offline store vs live token path without duplicating Connect chips.

### Concept 2 — Companion join

Phone is second client of the same Offline event log Watch already uses.

### Concept 3 — Honest Offline gate

Connected Offline only after store init succeeds (or documented CK cache policy with visible status).

## Design patterns used

### Pattern 1 — Protocol + fake Offline store

- **What:** `OfflineCareStoring` + in-memory fake in tests.
- **How:** Production uses `CloudKitOfflineCareStore`.
- **Why:** TDD without iCloud account.
- **Best practices:** Inject into session model.

### Pattern 2 — Connect gate

- **What:** `AuthGate.showsConnect` + root switch Connect vs shell.
- **How:** Mirror Watch `ContentView`.
- **Why:** One rule for reconnect.
- **Best practices:** Keep bypassAuth for previews/tests only.

### Pattern 3 — Pair client injection

- **What:** `WatchPairClienting` protocol.
- **How:** Real client in app; fake in unit tests.
- **Why:** Deterministic pair success/fail tests.
- **Best practices:** Same redeem URL shape as Watch.

## Sequence (Offline start)

```
User → PhoneConnectView (Offline)
     → PhoneSessionModel.useOffline(store)
     → CloudKitOfflineCareStore.init/fetch
     → success: isConnected=true, mode=.offline, save mode
     → fail: error banner, stay on Connect
```

## Sequence (Cloud pair)

```
User → enter code → WatchPairClient.redeem
     → BabyAPITokenStore.save + baseURL
     → mode=.live, isConnected=true
```

## API contracts

**Has API: no** — consume existing:

| Call | Contract |
|------|----------|
| Pair redeem | `POST {origin}/api/watch/pair/redeem` body `{ code }` → `{ baseURL, token }` (BABY_API.md §2) |

No new routes. GraphQL care mutations deferred to M2.

## Database contracts

**Has DB: yes** (CloudKit join only)

| Store | Type | Notes |
|-------|------|-------|
| CloudKit private | `CareEvent` schemaVersion=1 | Same fields as Watch Offline design |
| Container | `iCloud.vn.in4.MyBaby` | Match Watch entitlements |
| UserDefaults | `CareDataMode` | Phone-local key (document key name) |
| Keychain | API token | Live only; never CloudKit/App Group |

### Example queries

- Fetch all `CareEvent` records for projection (M1 may only `fetchEvents` for health/status).
- Append not required in M1 UI (no care chips) — store must still support append for tests/fake.

## UI specs (Has UI)

- Connect: two peer chips; Offline default; primary CTA full-width; errors in danger color; Advanced paste collapsed.
- Placeholder home: one headline + one sentence (“Care logging comes in the next update”); gear opens Settings.
- Settings: Mode row; iCloud status; Leave button.
- Match Watch copy for Offline vs Cloud meaning; iPhone layout can use more vertical space (no Watch page TabView required).

## OWASP (mobile client)

| Area | Control |
|------|---------|
| Secrets | Token Keychain only |
| Storage | No secrets in CloudKit/App Group/UserDefaults |
| Transport | HTTPS for non-local Cloud URLs; local http only for dev preset |
| AuthZ | Bearer from pair; Offline = Apple ID private DB |
| Errors | No token in error UI |

## Rejected alternative (short)

Ship Connect inside App Intents extension — rejected; not a user app.
