# Light skim: phone-widget-hig

## Project shape

Phone App embeds WidgetsExtension with one Baby Care Home Screen widget (`BabyCarePhoneHome`). Status comes from App Group mailbox via shared display/timeline helpers. Watch already ships accessory families for the same display model.

## Constraints (≤5)

| Constraint | Path / note |
|------------|-------------|
| No network in widget | README; provider reads App Group only |
| Empty store → sample snapshot | `BabyCareStatusStore.snapshotForWidgets` |
| Families today | `.systemSmall`, `.systemMedium` only |
| Display rules shared | `BabyCareComplicationDisplay` |
| Reload kinds | `BabyCareWidgetKinds.reloadKindNames` |

## Reuse first

| Reuse | Path |
|-------|------|
| Phone widget UI | `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift` |
| Intent / recommendations | `MyBaby Phone Widgets/AppIntent.swift` |
| Watch accessory layouts | `MyBaby Watch Widgets/BabyCareWidgets.swift` |
| Display + relative format | `BabyCareShared/BabyCareComplicationDisplay.swift` |
| Timeline policy | `BabyCareShared/BabyCareWidgetTimeline.swift` |
| Existing display tests | `MyBaby Watch AppTests` BabyCareComplicationDisplay tests |
| In-app a11y label style | `PhoneConnectView` / `CareControls` |

## Risks

| Risk | If ignored |
|------|------------|
| Color-only overdue | Fails HIG accessibility; hard to read in low light |
| Sample fallback vs empty UI | “·” rare on live path; still shows for fixed care with no events |
| Lock Screen without privacy | Sensitive care times on lock |
| Forking display rules | Phone/Watch drift |

## Result

**done** — enough for Analyze/Design.
