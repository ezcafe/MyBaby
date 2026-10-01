# Light skim: phone-m2-care-home

## Project shape

Phone App M1 shell + Connect; Watch owns full care UI/model; `BabyCareShared` holds Offline/API/snapshot helpers; my-apps owns GraphQL quick-care contracts.

## Constraints (≤5)

| Area | Constraint |
|------|------------|
| API | Reuse `babyHomeQuickStatus` + `babyQuickCare` only (BABY_API §4) — no new endpoints |
| Offline | Same CloudKit container/record as Watch (`CareEvent`) |
| Auth | Token stays Keychain; no secrets in App Group/CloudKit |
| UI | Match Watch care rules/labels; adapt layout for iPhone |
| Scope | No widgets (M3); no insights/growth (M4+) |

## Reuse first

| Asset | Path |
|-------|------|
| Care model | `MyBaby Watch App/Models/BabyHomeStatusModel.swift` |
| Pages | `MyBaby Watch App/Views/Pages/CarePages.swift` |
| Session | `BabyCareShared/PhoneSessionModel.swift` |
| GraphQL client | `BabyCareShared/BabyGraphQLClient.swift` |
| Offline store | `BabyCareShared/CloudKitOfflineCareStore.swift` |
| API rules | `my-apps/docs/BABY_API.md` §4–§10 |

## Risks

- Watch model may import Watch-only UI tokens — may need shared extraction
- Phone layout without vertical TabView could drift from Watch rules

## Result

**done**
