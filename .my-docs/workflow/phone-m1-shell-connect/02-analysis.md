# Analysis: phone-m1-shell-connect

**Updated:** 2026-09-30  
**Note:** main-thread — usage limit after Task retries

## Overall

### What is this?

Milestone 1 of Phone Baby program: turn the empty Phone surface into a real **iOS app** with Connect (**Offline | Cloud**), Offline CloudKit join (same as Watch), Cloud pairing, and Settings basics. No care chips (M2), no widgets (M3), no web-depth (M4+).

### Why do we need this?

Phone targets today cannot host Connect or Offline. Without M1, later care/widgets/full-web milestones have nowhere to plug in. Watch Offline already expects companions to join `iCloud.vn.in4.MyBaby`.

### How to do this?

1. **Replace/add a real iOS application target** — today’s “MyBaby Phone App” is an **App Intents ExtensionKit** `.appex`, not an app (`productType = extensionkit-extension`).
2. Wire Phone → `BabyCareShared` (pair client, API config, Offline/CloudKit store, mode store).
3. Port Connect + gate + thin session shell from Watch patterns (`AuthConnectView`, `ContentView` connect gate, `useOffline` / live connect / leave).
4. Entitlements: CloudKit container + App Group (for M3 readiness).

- **Other ways:** Keep appex only (impossible for Connect UI); put Connect inside Watch companion container (no iPhone UI).
- **Best practices:** Reuse Watch locks + shared stores; do not fork CloudKit schema; keep tokens out of CloudKit/App Group.

## Solution pieces

### 1. Real iOS app target (blocker)

#### What is this?
An installable `MyBaby.app` (iPhone) with `@main` SwiftUI `App`, not `AppIntentsExtension`.

#### Why do we need this?
Connect/Offline UI cannot ship as App Intents extension-only. Current Info.plist is `com.apple.appintents-extension`.

#### How to do this?
- **Approach (recommend):** New iOS Application target (e.g. keep name “MyBaby Phone App” or “MyBaby”) linked to `BabyCareShared`; retire or park the appex out of the launch path.
- **Other ways:** Convert existing target productType in pbxproj (fragile); host UI in widget extension (wrong).
- **Best practices:** Standard SwiftUI App lifecycle; separate App Intents later if needed.

### 2. Connect Offline | Cloud (Watch parity)

#### What is this?
Peer chips Offline | Cloud; Offline default; Cloud URL default `http://127.0.0.1:3000`; Start Offline / Save & connect.

#### Why do we need this?
Gate A #1/#2; Watch mental model already taught to users.

#### How to do this?
- Port UI chrome to iPhone (larger layout OK); reuse `ConnectHostPreset` / `ConnectHostURLField` / `WatchPairClient` from shared + Watch helpers if they live in Watch target — **move shared connect helpers into BabyCareShared if still Watch-only**.
- **Other ways:** Redesign Phone Connect from web Settings — rejected for M1 (Watch locks).
- **Best practices:** Honest Offline fail if iCloud unavailable; Advanced paste secondary.

### 3. Session model (thin for M1)

#### What is this?
Connected flag + `CareDataMode` + Offline store handle + live token session; placeholder home after connect.

#### Why do we need this?
Cold-start restore Offline/live without care chips yet.

#### How to do this?
- **Approach (recommend):** Thin `PhoneSessionModel` (or shared extract of connect/offline methods) — **do not** drag full Watch `BabyHomeStatusModel` care timers into M1.
- **Other ways:** Compile Watch model into Phone now — heavy; couples M2 early.
- **Best practices:** Same `CareDataModeStore` keys if intentional cross-device defaults; document if Phone uses separate suite.

### 4. Offline CloudKit join

#### What is this?
`CloudKitOfflineCareStore` / `OfflineCareStoring` on Phone with container `iCloud.vn.in4.MyBaby`.

#### Why do we need this?
Program Offline parity; data shared with Watch for later care (M2).

#### How to do this?
Enable entitlements on Phone app; call `useOffline()` path; show iCloud status; logout keeps CK data.
- **Other ways:** Phone-only local store — breaks companion contract.
- **Best practices:** Protocol + fake for tests; no schema v2 in M1.

### 5. Settings basics

#### What is this?
Mode label, leave Offline/Cloud → Connect, iCloud status line.

#### Why do we need this?
Escape hatch; status honesty.

#### How to do this?
Sheet or simple screen from placeholder home (Watch uses gear sheet — mirror).
- **Other ways:** Connect-only with no Settings — fails leave/status jobs.
- **Best practices:** Confirm before leave if needed; no care settings yet.

## What exists today

| Piece | State |
|-------|--------|
| MyBaby Phone App | App Intents `.appex` stub |
| MyBaby Phone Widgets | Widget extension stub (M3) |
| MyBaby (container) | `watchapp2-container` only — not a Phone UI host |
| Watch App | Full Connect + care + Offline |
| BabyCareShared | Pair, Offline CK, snapshots, config |

## Dependencies

- Apple Developer: enable iCloud container + App Group on Phone app id `vn.in4.MyBaby-Phone-App` (or new id if target renamed)
- Shared code may need small iOS-safe refactors (few `#available(watchOS)` spots — not blockers for Connect)
- `BabyHomeStatusModel` is Watch-target — M1 should not require moving entire model

## Reference files (for Build)

| Path | Why |
|------|-----|
| `MyBaby Phone App/*` | Current stub to replace/repurpose |
| `MyBaby.xcodeproj/project.pbxproj` | Target product types |
| `Config/WatchApp.entitlements` | iCloud + App Group ids |
| `BabyCareShared/CloudKitOfflineCareStore.swift` | Offline join |
| `BabyCareShared/WatchPairClient.swift` | Pair redeem |
| `MyBaby Watch App/Views/AuthConnectView.swift` | Connect UI locks |
| `MyBaby Watch App/ContentView.swift` | Connect gate |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | `useOffline` / live / leave patterns |
| `docs/BABY_API.md` (my-apps) | Pairing contract |

## Reusable patterns

| Pattern | Where |
|---------|--------|
| OfflineCareStoring + fake | BabyCareShared |
| CareDataModeStore | BabyAPIConfig.swift |
| AuthGate.showsConnect | BabyAPIConfig |
| WatchPairClient | BabyCareShared |

## Has API / Has DB (refine)

- **Has API:** **no** — M1 consumes existing pair redeem; no new/changed HTTP contract
- **Has DB:** **yes** — Phone joins CloudKit Offline store (entitlements + client persistence path)

## Design tree (frontier)

| ID | Question | Priority |
|----|----------|----------|
| DT1 | New iOS Application target vs convert appex in place? | Build-critical |
| DT2 | Thin Phone session model vs share full Watch `BabyHomeStatusModel` in M1? | Build-critical |
| DT3 | Keep App Intents appex as separate target, delete, or defer? | Important |
| DT4 | Advanced paste URL+token required in M1? | Important |
| DT5 | Phone `UserDefaults` suite shared with Watch for mode? | Nice |

## Settled (from program / idea)

- Milestone ladder Option 1; full web end-state Option 2 (later)
- Connect Offline \| Cloud; Offline default; Cloud URL local preset
- Container `iCloud.vn.in4.MyBaby`
- No care chips / widgets / web-depth in M1
