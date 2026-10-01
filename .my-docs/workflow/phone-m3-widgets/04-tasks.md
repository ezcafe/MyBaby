# Tasks: phone-m3-widgets

**Mode:** full · **Has UI:** yes · **Has API:** no · **Has DB:** no

## Task list

### Task 1 — Shared widget kind constants + dual reload

- **Acceptance:** Shared constants for `BabyCareComplication` and `BabyCarePhoneHome`; `persistStatusForWidgets` reloads both; Watch behavior unchanged.
- **Tests (TDD):** Unit: helper or model test asserts both kind strings included in reload list (fake `WidgetCenter` optional — if not injectable, test constant set / reloadKindNames() API).

### Task 2 — Phone Care type AppIntent + provider

- **Acceptance:** Phone Widgets `AppIntentConfiguration` with Care type Auto|Feed|Sleep|Diaper|Pump; provider loads App Group snapshot (sample in preview); timeline uses `BabyCareWidgetTimeline.nextUpdate`.
- **Tests (TDD):** Unit: careType maps to `BabyCareComplicationCareType`; empty suite → safe snapshot (reuse/extend status store tests).

### Task 3 — systemSmall + systemMedium entry views

- **Acceptance:** Views use `BabyCareComplicationDisplay`; running `.timer`; idle last-care + teal/red; medium optional secondary line; `widgetURL` deep link; configuration display name “Baby Care”.
- **Tests (TDD):** Unit: display resolve for Auto vs fixed Feed with nap running (existing Watch tests OK; add Phone mapping test if new wrapper); no token keys.

### Task 4 — Strip stub ControlWidget + Live Activity from bundle

- **Acceptance:** `MyBaby_Phone_WidgetsBundle` exposes only Baby Care Home Screen widget; gallery has no emoji stub / control / live activity from this extension.
- **Tests (TDD):** N/A compile/smoke; manual gallery note in test log.

### Task 5 — README

- **Acceptance:** README documents Phone Home Screen widgets + App Group + Care type; update M3 note.
- **Tests (TDD):** N/A

## Out of scope (do not build)

- Live Activities / Control Center widgets
- systemLarge (unless free while implementing — default skip)
- Lock Screen-only accessory redesign
- M4 features / new GraphQL / new CloudKit fields
- Watch complication redesign

## Implementation order

1 (dual reload, red tests) → 2 → 3 → 4 → 5
