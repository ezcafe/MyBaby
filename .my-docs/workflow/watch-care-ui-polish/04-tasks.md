# Tasks: Watch care UI polish

## Task 1: Model — related stop → idle + breast L↔R

**Description:**
When CareSideEffects stops breast/nap from another action, set those phases to `.idle` (not `.done`). Starting breast Left while Right running (or reverse) clears the other to idle then starts. Self-stop of a timer still goes `.done` + 2s clear. Pump unchanged (no breast/nap clear).

**Acceptance:**

- [ ] `selectBottle` / `selectDiaper` / sleep start with breast running → breast `.idle`
- [ ] Log/breast start with open nap → nap `.idle` (and `openNapStartedAt` nil)
- [ ] Toggle other breast while one running → other idle, this running
- [ ] Self-stop still `.done`
- [ ] Pump amount/timer does not clear breast/nap

**Tests (TDD — what turns red first):**

- [ ] `modelBottleStopsBreastToIdle` (breast was running → idle after bottle)
- [ ] `modelDiaperStopsBreastToIdle`
- [ ] `modelNapStartStopsBreastToIdle`
- [ ] `modelBreastSwitchClearsOtherSide`
- [ ] `modelSelfStopBreastGoesDone` (regression)
- [ ] Existing nap/pump side-effect tests still pass (update expectations if they assumed `.done`)

**Files likely touched:** `BabyHomeStatusModel.swift`, `MyBaby_Watch_AppTests.swift`

**Scope:** M

**Dependencies:** none

---

## Task 2: Timed chip + secondary type

**Description:**
Shared smaller secondary font for section detail, footer tips, idle “Tap to start”. Running title = side label only (no “Tap to stop”). Prefer Nap label for nap running title (not “Start nap - …”).

**Acceptance:**

- [ ] Subtle tips / header detail / idle subtitle use smaller secondary style
- [ ] Running chip title has no “Tap to stop”
- [ ] Timer still shows in subtitle while running

**Tests (TDD — what turns red first):**

- [ ] Optional pure helper test if title/subtitle strings extracted; else visual — unit for `TimedChipSide` display title if added
- [ ] Prefer extract `runningTitle` / reuse idleSubtitle for assertable strings

**Files likely touched:** `CareControls.swift`, maybe small helper on `TimedChipSide`

**Scope:** S

**Dependencies:** none

---

## Task 3: Custom ml 3 rows + Diaper spacing

**Description:**
`CustomMlPicker` wheel frame height ≈ 3 visible rows. Diaper tiles: center icon+text, spacing 1–2.

**Acceptance:**

- [ ] Custom picker shows ~3 rows on Watch
- [ ] Diaper icon and label centered; tighter gap

**Tests (TDD — what turns red first):**

- [ ] No meaningful unit — manual/smoke; optional constant test if height is named (`CustomMlPicker.visibleRowCount == 3`)

**Files likely touched:** `CarePages.swift` (`CustomMlPicker`), `CareControls.swift` (`DiaperKindGrid`)

**Scope:** S

**Dependencies:** none

---

## Checkpoints

After Task 1:

- [ ] Focused model unit tests pass

After Tasks 2–3:

- [ ] Build + unit smoke
- [ ] Glance Feed/Bottle/Diaper/Pump on Watch simulator if available
