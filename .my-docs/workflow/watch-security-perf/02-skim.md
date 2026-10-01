# Light skim: watch-security-perf

## Project shape

watchOS **MyBaby Watch App** + **Watch Widgets** share `BabyCareShared` for Connect, Keychain token, CloudKit Offline, GraphQL live care, and App Group complication mailbox. Re-verify Watch-only ATS / deep links / complications vs Phone shared fixes.

## Related UI paths

| Surface | Path |
|---------|------|
| Connect / auth / deep link | `AuthConnectView.swift`; `ContentView.swift` (`onOpenURL`) |
| Care home + pages | `BabyHomeView.swift`; `BabyCareShared/CarePages.swift` |
| Complications | `MyBaby Watch Widgets/BabyCareWidgets.swift` |

## Related APIs / data

| Need | Path |
|------|------|
| Token / URL / pair / GQL | `BabyAPITokenStore`, `BabyAPIConfig`, `WatchPairClient`, `BabyGraphQLClient` |
| CloudKit + App Group | `CloudKitOfflineCareStore`; `BabyCareStatusStore` (`group.vn.in4.MyBaby`) |
| Status / logout / reload | `BabyHomeStatusModel`; `WidgetTimelineReloadCoalescer`; `BabyCareWidgetTimeline` |
| Entitlements / scheme | `Config/WatchApp.entitlements`; `Widgets.entitlements`; `WatchApp-Info.plist` |

## Hard constraints (≤5)

| Area | Constraint |
|------|------------|
| Auth | Token in Keychain only; never App Group / CloudKit / Fail copy / widgets |
| ATS | Watch Info has **no** ATS block; Phone has localhost exceptions — verify cleartext |
| Offline | CloudKit private DB; App Group = status mailbox only |
| API | Reuse GraphQL + pair redeem; prefer client-only fixes |
| UI | Keep Connect Offline default, vertical care, Failed + Retry |

## Risks if ignored

- Skip Watch ATS / deep-link / complication while assuming Phone shared fixes
- Break local `http://127.0.0.1` Cloud preset; blank Fail+Retry or thrash WidgetKit on main actor

## Result

**done** — enough for Analyze/Design (Critical vs already-shared is Analyze’s job).
