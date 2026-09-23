# Tasks: Lower MyBaby Watch memory (hygiene)

**Mode:** simple

## Task 1 — Failing tests for cancel + tick gate (S)

**Description:**
Add unit tests that fail until cancel and tick-gate helpers exist.

**Acceptance:**

- [ ] Rapid done-flash scheduling cancels prior clear (only last clear runs / prior Task cancelled).
- [ ] Pure helper (or chip input contract): ticks enabled only when `running && pageSelected && sceneActive` (or equivalent).
- [ ] Existing care matrix / timeline tests still compile.

**Tests (TDD — what turns red first):**

- [ ] `scheduleClearDone` / side clear: second schedule cancels first (expose test hook or `Task` handle).
- [ ] `CareTimerTicks.shouldTick(running:pageSelected:sceneActive:)` (or same rules on chip) — table of cases.

**Files likely touched:** `MyBaby_Watch_AppTests.swift`; small helper if needed under Watch App or Shared.

**Scope:** S

**Dependencies:** none

---

## Task 2 — Cancellable done-flash Tasks (S)

**Description:**
Replace fire-and-forget clears with one cancellable Task path on the model.

**Acceptance:**

- [ ] `scheduleClearDone` and `scheduleClearDoneForSide` cancel previous work before sleep.
- [ ] After 2s, done phases / done ml / diaper kind still clear as today.
- [ ] Task 1 cancel tests green.

**Tests (TDD):** Task 1 cancel cases green.

**Files likely touched:** `BabyHomeStatusModel.swift`

**Scope:** S

**Dependencies:** Task 1

---

## Task 3 — Gate TimelineView ticks (S)

**Description:**
Pass `ticksEnabled` into `TimedCareChip` from pages (selected page + `scenePhase == .active`). Static label when disabled but still running.

**Acceptance:**

- [ ] Running chip on **selected** active page still updates every ~1s.
- [ ] Off-page or inactive scene: no periodic TimelineView (or ticksEnabled false).
- [ ] TabView is **not** wrapped in TimelineView.
- [ ] Task 1 tick-gate tests green.

**Tests (TDD):** Tick-gate helper/cases green; manual: start nap, swipe away — no requirement for live subtitle off-page.

**Files likely touched:** `CareControls.swift`, `CarePages.swift`, optionally `BabyHomeView.swift`

**Scope:** S

**Dependencies:** Task 1

---

## Task 4 — Merge widget configurations (S)

**Description:**
One accessory widget configuration covering circular/corner/rectangular/inline (drop duplicate Smart Stack kind unless a second display name is required — prefer one).

**Acceptance:**

- [ ] Widget bundle builds; deep link URL still set from primary signal.
- [ ] `BabyCareWidgetTimeline.nextUpdate` behavior unchanged (existing unit tests).
- [ ] README one-line note if companion names simplify.

**Tests (TDD):** Existing timeline/deep-link tests green; no new e2e required (lite profile).

**Files likely touched:** `BabyCareWidgets.swift`, `README.md` (short)

**Scope:** S

**Dependencies:** none

---

## Task 5 — Re-measure + smoke (S)

**Description:**
Debug Memory Report after hygiene (same scenario); run unit tests + build.

**Acceptance:**

- [ ] Note Current/High in `06-test-log.md` vs baseline **22.3 / 22.4 MB** Debug.
- [ ] Expectation: peak may stay similar; **must not climb** during a multi-minute nap on selected page.
- [ ] Unit tests + build green.

**Tests (TDD):** Suite green; memory note is manual evidence.

**Files likely touched:** `06-test-log.md`

**Scope:** S

**Dependencies:** Tasks 2–4

---

## Checkpoints

After Tasks 2–3:

- [ ] Focused unit tests pass
- [ ] Nap timer still readable on Sleep page

## Out of scope

- Page map / IA changes
- API / App Group persistence
- Disabling Previews solely for memory (unless Task 5 shows clear Release win)
