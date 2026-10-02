# Light skim: widgets-security-perf

## Project shape

Phone WidgetsExtension + Watch Widgets both render Baby Care glances from App Group `group.vn.in4.MyBaby`. Shared store/timeline/display helpers live in `BabyCareShared`; apps write the mailbox and coalesce WidgetKit reloads.

## Constraints (≤5)

| Constraint | Path / note |
|------------|-------------|
| No network in widget | README; providers read App Group only |
| Status DTO never tokens | `BabyCareStatusStore.forbiddenKeys` |
| Empty store → sample today | `snapshotForWidgets` → `.sampleNextFeed()` |
| Reload both kinds | `BabyCareWidgetKinds.reloadKindNames` + coalescer 750ms |
| Entitlements App Group only | `Config/Widgets.entitlements` |

## Reuse first

| Reuse | Path |
|-------|------|
| Phone widget | `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift` |
| Watch widget | `MyBaby Watch Widgets/BabyCareWidgets.swift` |
| Mailbox | `BabyCareShared/BabyCareStatusStore.swift` |
| Timeline | `BabyCareShared/BabyCareWidgetTimeline.swift` |
| Coalescer | `BabyCareShared/WidgetTimelineReloadCoalescer.swift` |
| Display / a11y / empty | `BabyCareShared/BabyCareComplicationDisplay.swift` |
| Persist hook | `BabyHomeStatusModel.persistStatusForWidgets` |
| Deep link | `BabyHomeDeepLink` in `BabyHomePage.swift` |
| Prior HIG packs | `.my-docs/workflow/phone-widget-hig/`, `watch-widget-hig/` |

## Risks

| Risk | If ignored |
|------|------------|
| Sample as live | False trust on first install / after Leave |
| Privacy gaps on accessory | Care times on Lock Screen / Always On |
| Reload thrash | Battery + WidgetKit budget |
| Fork Phone vs Watch empty/privacy | Drift after HIG packs |

## Result

**done** — enough for Analyze/Design.
