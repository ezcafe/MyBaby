# Light repo skim: offline-icloud-mode

**Result:** done  
**Updated:** 2026-09-29  
**Size:** ≤ ~40 lines — constraints only (not full analysis)  
**Note:** main-thread fallback — usage limit

## Project shape

MyBaby Watch: Connect Local/Production → pairing/token → live GraphQL; or **sample** in-memory. Widgets use App Group status mailbox (not iCloud). No Offline/iCloud care store; no iOS companion target this pass (Decision 1).

## Related existing UI / screens

| Path | What it does | Reuse? |
|------|--------------|--------|
| `MyBaby Watch App/Views/AuthConnectView.swift` | Local/Production chips, pairing, Save & connect | Add Offline peer chip + Start Offline |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | `CareDataMode` sample/live; connect restore | Extend mode for Offline |
| `MyBaby Watch App/ContentView.swift` | Auth gate / bypass | Offline counts as connected |
| Settings sheet (Last care) | Host + Log out | Show Offline / leave Offline |

## Related APIs / data

| Path or route | Notes |
|---------------|-------|
| `BabyCareShared/BabyAPIConfig.swift` | Host presets only — Offline is not a host URL |
| `BabyCareShared/BabyGraphQLClient.swift` | Live only — unused in Offline |
| `BabyCareShared/BabyCareStatusStore.swift` | App Group widgets — not Offline durability |
| iCloud / CloudKit / SwiftData | **Not present** — new store in Analyze/Design |
| my-apps Baby GraphQL | Unchanged; no Offline API |

## Hard constraints (do not fight)

1. Decision 1: Watch + container contract only; no companion UI.
2. Offline peer mode on Connect; ≠ sample; no pairing/token.
3. Token stays Keychain for live only; never in App Group / iCloud docs as secret.
4. App Group remains widget mailbox — not the Offline source of truth.
5. Match Watch `BabyTokens` chrome for UI refs.

## Risks if we ignore the repo

- Treating App Group as iCloud “share”
- Breaking Local/Production connect while adding Offline
- Equating sample with Offline in UI
- Shipping companion claims without an iOS target

## Enough for UI concept / Analyze?

**yes** — Connect surface + mode model located; store tech for Analyze/Design.
