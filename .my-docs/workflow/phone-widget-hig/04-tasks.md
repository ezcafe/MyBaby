# Tasks: phone-widget-hig

**Design option:** Option 2 (Gate B approved)  
**TDD:** yes — failing unit tests before production changes

## Task 1 — Shared accessibility summary

- **Acceptance:** `BabyCareComplicationDisplay` exposes a stable accessibility summary for running / idle (in-range) / idle overdue / empty. Phone entry view applies combined accessibility using that string (all families).
- **Tests (TDD):**
  - Unit: running nap → summary contains kind label (e.g. “Nap”) and does not invent overdue.
  - Unit: idle overdue feed → summary contains overdue cue + kind.
  - Unit: empty → summary contains clear empty wording (not “·”).
- **Files:** `BabyCareShared/BabyCareComplicationDisplay.swift`; `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift`; tests in `MyBaby Watch AppTests`.

## Task 2 — Empty primary copy

- **Acceptance:** Shared empty primary constant; Phone small/medium/accessory primary for `mode.empty` shows “No care yet”, not “·”. Nil-mailbox sample fallback unchanged.
- **Tests (TDD):**
  - Unit: `emptyPrimaryText` (or equivalent) == “No care yet”; empty accessibility summary uses it.
- **Files:** `BabyCareComplicationDisplay.swift`; Phone widget view.

## Task 3 — Small overdue non-color cue

- **Acceptance:** systemSmall idle overdue shows text and/or SF Symbol cue in addition to danger color. Medium/accessory secondary keep overdue line. `showsOverdueCue` (or equivalent) true when idle + red.
- **Tests (TDD):**
  - Unit: overdue idle → `showsOverdueCue == true`; in-range idle → false; running → false.
- **Files:** display helper; Phone widget view.

## Task 4 — Medium hierarchy / margins

- **Acceptance:** Medium face does not lead with redundant “Baby Care” title; primary value + kind dominate; system-friendly margins.
- **Tests:** Visual/build.
- **Files:** `MyBaby_Phone_Widgets.swift`.

## Task 5 — Lock Screen accessory families

- **Acceptance:** `supportedFamilies` includes `accessoryRectangular`, `accessoryCircular`, `accessoryInline`. Rectangular shows kind + primary + secondary; circular/inline compact primary. Care times marked `privacySensitive`. Deep link unchanged.
- **Tests:** Build WidgetsExtension; reuse display unit coverage (no WidgetKit host required).
- **Files:** `MyBaby_Phone_Widgets.swift` (layouts inspired by Watch `BabyCareWidgets.swift`).

## Task 6 — Smoke closeout

- **Acceptance:** Phone App + WidgetsExtension **BUILD SUCCEEDED**; unit suite green including new a11y/empty/overdue tests.
- **Tests:** Run Watch AppTests + Phone build; note commands in `06-test-log.md`.

## Out of scope tasks

- systemLarge; interactive widget buttons; Live Activities; changing `snapshotForWidgets` sample-on-nil; Watch widget redesign.
