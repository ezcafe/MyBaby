# Light repo skim: phone-m1-shell-connect

**Result:** done  
**Updated:** 2026-09-30  
**Note:** main-thread — usage limit

## Project shape

MyBaby Xcode workspace: Watch App (full Connect + care + Offline CloudKit), shared `BabyCareShared`, stub Phone App / Phone Widgets. my-apps hosts Baby GraphQL + pairing. M1 wires Phone shell to shared Connect/Offline/pair paths only.

## Constraints (≤5 rows each)

### Must reuse

| Item | Path / note |
|------|-------------|
| Connect Offline\|Cloud locks | Watch `AuthConnectView`; offline-icloud-mode design |
| Offline store + container | `CloudKitOfflineCareStore` · `iCloud.vn.in4.MyBaby` |
| Pairing redeem | `WatchPairClient` · `POST /api/watch/pair/redeem` |
| Token / API config | `BabyAPITokenStore`, `BabyAPIConfig` |
| App Group (later widgets) | `group.vn.in4.MyBaby` — enable on Phone for future M3 |

### Do not break

| Item | Note |
|------|------|
| Watch Connect / Offline | No Watch behavior regress |
| CloudKit schema CareEvent v1 | Join only; no schema fork |
| Token secrecy | Not in CloudKit / App Group |

### Stack / patterns

| Item | Note |
|------|------|
| SwiftUI + shared package | Prefer Phone UI calling shared model/store |
| Entitlements | Mirror Watch iCloud + App Group on Phone target |
| Tests | Protocol fakes (`OfflineCareStoring`, pair client) already used on Watch |

## Risks for Analyze

- Phone target may not link `BabyCareShared` / entitlements yet
- watchOS-only APIs inside shared code (scan before reuse)
- Post-connect shell vs empty root — keep placeholder honest for M2
