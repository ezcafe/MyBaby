# Light skim: phone-m3-widgets

## Project shape

Phone App M1–M2 logs care and writes App Group status; Watch Widgets already render care glance from the same mailbox; Phone Widgets target is still an Xcode stub.

## Constraints (≤5)

| Area | Constraint |
|------|------------|
| Data | Read App Group `group.vn.in4.MyBaby` only — no network in widget |
| Auth | Never put token/pairing in App Group (`forbiddenKeys`) |
| UX meaning | Reuse `BabyCareComplicationDisplay` rules (timer / last care / teal-red) |
| Scope | Home Screen small+medium (+ optional large); no Live Activity / Control / M4 |
| Reload | Persist must reload Phone widget kind (not only Watch `BabyCareComplication`) |

## Reuse first

| Asset | Path |
|-------|------|
| Status mailbox | `BabyCareShared/BabyCareStatusStore.swift` |
| Display resolve | `BabyCareShared/BabyCareComplicationDisplay.swift` |
| Timeline nextUpdate | `BabyCareShared/BabyCareWidgetTimeline.swift` |
| Watch widget pattern | `MyBaby Watch Widgets/BabyCareWidgets.swift` |
| Persist hook | `BabyHomeStatusModel.persistStatusForWidgets` |
| Phone stub target | `MyBaby Phone Widgets/` |
| Entitlements | `Config/Widgets.entitlements`, `Config/PhoneApp.entitlements` |

## Risks

- Stub ControlWidget + Live Activity still in widget bundle
- Persist reloads Watch kind only — Phone widgets stay stale
- iOS family layouts differ from watchOS accessory families

## Result

**done**
