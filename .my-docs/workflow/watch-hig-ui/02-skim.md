# Light repo skim: watch-hig-ui

**Result:** done
**Updated:** 2026-09-26

## Project shape

MyBaby is a watchOS 10+ Baby Care companion: vertical care jobs in a `TabView`, shared Swift (`BabyCareShared`), and accessory widgets. Live mode talks to my-apps Baby GraphQL; widgets today still timeline from sample snapshots.

## Related UI paths

| Path | Role |
|------|------|
| `MyBaby Watch App/Views/BabyHomeView.swift` | `.tabViewStyle(.page)` home |
| `MyBaby Watch App/Views/Pages/CarePages.swift` | Feed/Sleep/Diaper/Pump/LastCare/Settings |
| `MyBaby Watch App/Views/Components/CareControls.swift` | Chips, header, footer |
| `MyBaby Watch App/Views/AuthConnectView.swift` | Connect form |
| `MyBaby Watch App/Theme/BabyTokens.swift` | Teal / radii / hit |
| `MyBaby Watch Widgets/BabyCareWidgets.swift` | Complications |

## Related APIs / data

| Item | Note |
|------|------|
| `BabyHomeStatusSnapshot` / model | In-app source of truth |
| Pairing redeem + GraphQL baby | Unchanged this run |
| App Group | Not wired yet; tests mention suiteName — need entitlements |

## Hard constraints

- Keep care side-effect rules; no new GraphQL/DB
- Feed stays first page; Settings stays gear sheet
- Mount selected ±1 pages (memory)
- Do not wrap TabView in TimelineView
- Widget families: circular / corner / rectangular / inline

## Risks if ignored

- Vertical page + nested ScrollView gesture fights
- Live widgets without App Group stay sample forever
- Materials/contrast fail in Always On / dark

## Enough for UI concept / Analyze?

yes — paths and constraints clear
