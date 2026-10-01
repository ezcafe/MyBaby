# Light skim: phone-security-perf

## Project shape

iOS **MyBaby Phone App** + **Phone Widgets** share `BabyCareShared` with Watch for Connect, Keychain token, CloudKit Offline, GraphQL live care, and App Group status mailbox.

## Constraints (≤5)

| Area | Constraint |
|------|------------|
| Auth | Token in Keychain only; never App Group / CloudKit / widget DTO |
| ATS | Phone Info.plist exceptions only for `127.0.0.1` / `localhost` |
| Offline | CloudKit private DB `iCloud.vn.in4.MyBaby` / `CareEvent` |
| API | Reuse existing baby GraphQL + pair redeem; prefer client-only fixes |
| UI | Keep Connect Offline default, care tabs, Failed + Retry |

## Reuse first

| Asset | Path |
|-------|------|
| Token store | `BabyCareShared/BabyAPITokenStore.swift` |
| URL / session restore | `BabyCareShared/BabyAPIConfig.swift` |
| Phone session | `BabyCareShared/PhoneSessionModel.swift` |
| Care model | `BabyCareShared/BabyHomeStatusModel.swift` |
| CloudKit store | `BabyCareShared/CloudKitOfflineCareStore.swift` |
| App Group mailbox | `BabyCareShared/BabyCareStatusStore.swift` |
| GraphQL client | `BabyCareShared/BabyGraphQLClient.swift` |
| Pair redeem | `BabyCareShared/WatchPairClient.swift` |
| Phone ATS | `MyBaby Phone App/Info.plist` |
| Entitlements | `Config/PhoneApp.entitlements` |

## Risks

- Shared-model fixes also affect Watch — keep behavior tests green
- Over-strict HTTPS rules must still allow local `http://127.0.0.1` Cloud preset

## Result

**done**
