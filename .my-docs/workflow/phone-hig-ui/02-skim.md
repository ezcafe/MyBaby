# Light skim: phone-hig-ui

## Project shape

MyBaby Phone App is an iOS companion (Connect Offline|Cloud → five-tab care home → Settings sheet) sharing `BabyCareShared` care pages/controls/tokens with Watch. Care rules and APIs already ship; this run is iOS HIG chrome polish only.

## Constraints (≤5)

| Area | Constraint |
|------|------------|
| API / DB | No new GraphQL, pairing, or CloudKit schema |
| Shared UI | Phone adapts shared care chrome without breaking watchOS |
| IA | Keep TabView five tabs + Settings sheet (no new tabs) |
| Auth | Token/Keychain / Offline session behavior unchanged |
| Scope | Widgets visual redesign out; care side-effect rules out |

## Reuse first

| Asset | Path |
|-------|------|
| Connect | `MyBaby Phone App/PhoneConnectView.swift` |
| Home / tabs | `MyBaby Phone App/PhoneHomeView.swift` |
| Shell | `MyBaby Phone App/PhoneContentView.swift` |
| Settings | `MyBaby Phone App/PhoneSettingsSheet.swift` |
| Care pages / chips | `BabyCareShared/CarePages.swift`, `CareControls.swift` |
| Tokens | `BabyCareShared/BabyTokens.swift` |
| Prior HIG pack | `.my-docs/workflow/watch-hig-ui/` |

## Risks

- Hardcoded Watch-tuned fonts/heights in shared files regress Watch if changed blindly
- NavigationStack wrapping TabView may limit per-tab toolbar HIG patterns

## Result

**done**
