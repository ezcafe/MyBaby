# Tasks: Center picker title + diaper detail sheet

**Mode:** simple  
**Has API:** no · **Has DB:** no  
**Design:** Decision 1 Option 1

## Task 1 — Picker title center + failing tests (S)

**Acceptance:**
- `CustomMlPicker` title is horizontally centered (`alignment: .center`).
- Bottle and Pump custom sheets both use this title.

**TDD notes:** Unit/source contract (e.g. `CustomMlPicker` title uses center alignment) — red first.

## Task 2 — Diaper tap plan helpers + tests (S)

**Acceptance:**
- Pure `planDiaperKindTap`: Wet/Dry → instant; Poop/Mixed → openSheet with amount `.medium`, color/texture nil.
- Pure `diaperSheetSaveAction`: includes `diaperAmount`; omits nil color/texture; maps Poop → `dirty`.

**TDD notes:** Mirror `baby-diaper-quick-plan` cases in `MyBaby_Watch_AppTests`.

## Task 3 — Diaper detail sheet + model payload (M)

**Acceptance:**
- `DiaperPage`: Wet/Dry call instant save; Poop/Mixed present detail sheet.
- Sheet: Color / Texture / Amount chips (full enum lists); Cancel dismisses; Save saves then dismisses.
- Live `selectDiaper` action includes detail keys when provided; sample mode still flashes done.
- Fail / done chrome still keyed by kind.

**TDD notes:** Model test: dirty save with color+amount builds expected action dict (stub client if needed). Extend `modelDiaperFlashOnly…` so Wet still no lasting selected; **Poop/Mixed chip tap must not live-save until sheet Save** (04a fold).

## Task 4 — Smoke (S)

**Acceptance:** New unit tests green; record in `06-test-log.md` at smoke.

## Security / UI checks

- Enum chips only (no free-text detail).
- Sheet scrollable; Save reachable; title centered on ml picker.

## Out of scope

- Redesign Diaper grid layout
- Wet/Dry detail sheet
- New GraphQL schema
- Merging prior `watch-hig-ui` Gate C
