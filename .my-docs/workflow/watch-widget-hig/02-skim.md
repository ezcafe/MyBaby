# Light skim: watch-widget-hig

## Project shape

Watch App embeds **MyBaby Watch Widgets** with one Baby Care accessory widget (`BabyCareComplication`) for face + Smart Stack (circular, corner, rectangular, inline). Status comes from App Group via shared display/timeline helpers already used by Phone widgets.

## Constraints (≤5)

| Constraint | Path / note |
|------------|-------------|
| No network in widget | README; provider reads App Group only |
| Empty store → sample snapshot | `BabyCareStatusStore.snapshotForWidgets` |
| Families today | accessoryCircular / Corner / Rectangular / Inline |
| Display rules shared | `BabyCareComplicationDisplay` (+ a11y/empty helpers) |
| Reload kinds | `BabyCareWidgetKinds.reloadKindNames` includes watch |

## Reuse first

| Reuse | Path |
|-------|------|
| Watch widget UI (target) | `MyBaby Watch Widgets/BabyCareWidgets.swift` |
| Phone HIG wiring pattern | `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift` |
| Display + a11y / empty / overdue | `BabyCareShared/BabyCareComplicationDisplay.swift` |
| Timeline policy | `BabyCareShared/BabyCareWidgetTimeline.swift` |
| Existing unit tests | `MyBaby Watch AppTests` accessibilitySummary / showsOverdueCue / empty |
| Intent + recommendations | same file (`BabyCareComplicationIntent`) |

## Risks

| Risk | If ignored |
|------|------------|
| Color-only overdue on small families | Fails HIG accessibility on wrist |
| Watch still shows “·” | Cryptic empty after Phone already fixed |
| Skip privacySensitive | Care times on Always On / shared glance |
| Fork Watch-only strings | Phone/Watch drift |

## Result

**done** — enough for Analyze/Design.
