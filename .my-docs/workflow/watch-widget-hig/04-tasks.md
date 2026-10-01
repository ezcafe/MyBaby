# Tasks: watch-widget-hig

**Design option:** Option 2 (Gate B approved)  
**TDD:** yes — verify shared helpers still green; add Watch-facing tests only if new strings appear

## Task 1 — Wire accessibility summary

- **Acceptance:** `BabyCareWidgetEntryView` applies combined accessibility using `display.accessibilitySummary` on all accessory families.
- **Tests (TDD):**
  - Unit: existing `accessibilitySummary*` tests in Watch AppTests remain green (no API change expected).
  - If Build adds a Watch-only string helper, add unit coverage for it before use.
- **Files:** `MyBaby Watch Widgets/BabyCareWidgets.swift`

## Task 2 — Empty primary copy

- **Acceptance:** Circular / corner / rectangular / inline primary for `mode.empty` shows `BabyCareComplicationDisplay.emptyPrimaryText` (“No care yet”), not “·”. Nil-mailbox sample fallback unchanged.
- **Tests (TDD):**
  - Unit: existing empty summary / `emptyPrimaryText` tests remain green.
- **Files:** `BabyCareWidgets.swift`

## Task 3 — Circular overdue non-color cue

- **Acceptance:** accessoryCircular idle overdue shows text and/or SF Symbol cue in addition to danger color; kind icon remains. Corner/inline add cue when space allows. Rectangular keeps “X overdue” secondary. Uses `showsOverdueCue`.
- **Tests (TDD):**
  - Unit: existing `showsOverdueCue*` tests remain green.
- **Files:** `BabyCareWidgets.swift`

## Task 4 — Rectangular hierarchy + privacySensitive

- **Acceptance:** Rectangular does not lead with “Baby Care” title; kind + primary dominate; secondary line kept. Timer and relative ages marked `privacySensitive` across families that show them.
- **Tests:** Build Watch Widgets target.
- **Files:** `BabyCareWidgets.swift`

## Task 5 — Always On / accent chrome (Option 2)

- **Acceptance:** Watch widget accents use `BabyTokens.accent` / `BabyTokens.danger` with `@Environment(\.colorScheme)` (same pattern as Phone widgets). No hard-coded `Color(hex: 0x2DD4BF)` / `0xF87171` in `BabyCareWidgets.swift`. Rectangular secondary uses muted/secondary token style. Teal/red meaning unchanged (`display.color`).
- **Tests:** Build Watch Widgets; optional unit that tokens resolve for light/dark if already covered elsewhere — no new API required.
- **Files:** `BabyCareWidgets.swift`; `BabyTokens.swift` (read-only unless missing API)

## Task 6 — Smoke closeout

- **Acceptance:** Watch App + Watch Widgets **BUILD SUCCEEDED**; unit suite green including existing a11y/empty/overdue tests.
- **Tests:** Run Watch AppTests + Watch build; note commands in `06-test-log.md`.

## Out of scope tasks

- New accessory families; interactive widget buttons; Live Activities; changing `snapshotForWidgets` sample-on-nil; Phone widget work.
