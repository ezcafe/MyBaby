# Analysis: offline-icloud-mode

**Result:** done  
**Updated:** 2026-09-29  
**Note:** main-thread fallback — usage limit · Gate A2 approved

## Overall deep dive

1. **What is this?** Add **Offline** as the default Connect mode: durable care on Watch via **iCloud**, plus slim **Cloud** connect (no Local chip; Cloud URL defaults to `http://127.0.0.1:3000`). Document the iCloud container for future companions. No companion UI this pass.
2. **Why do we need this?** Sample does not persist; live API needs network + pairing. Parents need real offline care that survives relaunch and is ready to share later.
3. **How to do this?** Extend Connect UI per approved HTML; add `CareDataMode.offline` + an Offline care event store synced with iCloud; derive `BabyHomeStatusSnapshot` for UI/widgets; keep Cloud → GraphQL path. Other ways: App Group only (fails cross-device contract); my-apps “offline API” (rejected). Best practice: private CloudKit (or SwiftData+CloudKit), append-only events, never put tokens in iCloud/App Group.

## Has API / Has DB recommendation

| Flag | Rec | Why |
|------|-----|-----|
| **Has API** | **no** | No new my-apps routes; Cloud uses existing pair + GraphQL |
| **Has DB** | **yes** | New iCloud/CloudKit (or SwiftData+CloudKit) persistence schema for care events |

## Solution pieces (≤5)

### 1. Connect UI — Offline | Cloud

1. **What:** Two peer chips; Offline default; Cloud shows URL+pairing; no Local.
2. **Why:** Matches Gate A2 HTML; Local chip replaced by Cloud URL default.
3. **How:** Change `AuthConnectView` + `ConnectHostPreset` UX; Cloud tap sets `baseURL = BabyAPIConfig.localPreset` (not empty). Other: keep three chips — rejected by A2.

### 2. CareDataMode.offline + session restore

1. **What:** Third data mode beside sample/live; persist “last mode” so Offline relaunches without pairing.
2. **Why:** Auth gate today treats sample/live only; Offline must count as connected.
3. **How:** `useOffline()`; UserDefaults flag for mode; ContentView restore Offline before live; logout leaves Offline or returns to Connect (Design). Other: reuse sample — rejected (≠ durable).

### 3. Offline care event store (iCloud)

1. **What:** Append-only care events (feed/sleep/diaper/pump) in private iCloud DB; rebuild snapshot for home + App Group mailbox.
2. **Why:** Durability + future companion join contract.
3. **How:** Prefer **CloudKit CKRecord** schema with documented record types (Option A) or **SwiftData + CloudKit** (Option B) — Decision in Design. Best practice: event log → projection snapshot; sync status UI.

### 4. Wire care chips to Offline writes

1. **What:** Same chip UX; Offline path writes store instead of `babyQuickCare`.
2. **Why:** One UI, two backends (live vs offline).
3. **How:** Branch in `BabyHomeStatusModel` on `mode`; timers start local; stops/one-shots append events then refresh snapshot. Keep App Group `persistStatusForWidgets()` after snapshot update.

### 5. Docs + entitlements contract

1. **What:** iCloud capability, container id, record types in README; no companion app.
2. **Why:** Decision 1 Option 1.
3. **How:** Entitlements + short “Companion join” section.

## Reusable patterns

| Pattern | Path | Reuse |
|---------|------|-------|
| Connect presets / URL | `AuthConnectView`, `BabyAPIConfig` | Extend; remove Local UI |
| Modes | `CareDataMode` sample/live | Add `.offline` |
| Widget mailbox | `BabyCareStatusStore` | Keep as derived projection only |
| Live send | `sendQuickCare` / GraphQL | Unchanged for Cloud |

## System shape candidates

| Candidate | Fit |
|-----------|-----|
| A — CloudKit CKRecord event log + snapshot projector | Clear contract for companions; explicit schema |
| B — SwiftData models + `cloudKitDatabase` | Less glue if tooling works on watchOS target |
| C — App Group only | Reject — not iCloud / not cross-device |

## Spike notes

None this round (no throwaway code).

## Open questions for Design (non-blocking)

1. Logout from Offline: clear local projection only vs leave iCloud data?
2. Histories Offline vs live: keep separate (default yes).
3. Demote sample entry after Offline ships?

## Clear enough to design?

**yes** — Gate A2 HTML + locks are enough. Parent: set Has API=no, Has DB=yes.
