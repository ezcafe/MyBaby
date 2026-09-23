# Tasks: Watch care rules + Feed/Bottle split

## Task 1: Pure care side effects + chip builder (TDD first)

**Description:**  
Add `CareSideEffects` (nap/breast/pump matrix) and `BabyBottleChipMls.build` (port of `buildBabyBottleChipMls`, default tests with `limit: 2`). Wire later in Task 3.

**Acceptance:**

- [ ] Open nap + breast/bottle/diaper → nap ends; + pump → nap stays
- [ ] Bottle/diaper/sleep clear running breast; pump amount does not
- [ ] Chip builder: history first, then snaps; max 2; no-birth snaps `[60,90]` when empty history limit 2

**Tests (TDD — what turns red first):**

- [ ] Unit: side-effect matrix (≥6 cases)
- [ ] Unit: chip builder mirrors age-guide cases with limit 2

**Files likely touched:**  
`BabyCareShared/` (new helpers) or `MyBaby Watch App/Models/`; `*Tests`

**Scope:** M

**Dependencies:** none

---

## Task 2: Split Feed / Bottle pages + remove title + subtle font

**Description:**  
`BabyHomePage`: `.feed`, `.bottle` (remove `.feedBottle`). TabView pages; deep links; primary-signal deep link → feed. Remove navigation title. Section detail `.caption2`. Bottle/Pump UI shows 2 chips + Custom from snapshot.

**Acceptance:**

- [ ] Six-page order Feed→Bottle→Sleep→Diaper→Pump→Last care
- [ ] `page=bottle` / `page=feed` work; unknown → feed
- [ ] No app title in chrome
- [ ] Subtle detail smaller than lead

**Tests (TDD — what turns red first):**

- [ ] Deep link bottle/feed/fallback
- [ ] Update tests still referencing `.feedBottle`

**Files likely touched:**  
`BabyHomePage.swift`, `BabyHomeView.swift`, `CarePages.swift`, `CareControls.swift`, `BabyHomeStatusSnapshot.swift`, widgets if needed, tests

**Scope:** M

**Dependencies:** Task 1 (chips list shape)

---

## Task 3: Model wiring — apply side effects on care taps

**Description:**  
`toggleTimed` / `selectBottle` / `selectDiaper` call `CareSideEffects`; snapshot chip mls from builder (sample recent/snaps). Pump ml uses same list.

**Acceptance:**

- [ ] Live model matches Task 1 matrix
- [ ] Bottle/Pump chips length == 2 (+ Custom in UI)

**Tests (TDD — what turns red first):**

- [ ] Model integration tests: open nap + selectBottle clears nap

**Files likely touched:**  
`BabyHomeStatusModel.swift`, snapshot samples, tests

**Scope:** M

**Dependencies:** Task 1, Task 2

---

## Task 4: README + companion deep-link map

**Description:**  
Update README page map; ensure widget deep links use new pages.

**Acceptance:**

- [ ] Docs match six pages; no title claim
- [ ] Companions still open correct page

**Tests (TDD — what turns red first):**

- [ ] Existing widget deep-link unit if any — update

**Files likely touched:**  
`README.md`, widget sources, tests

**Scope:** S

**Dependencies:** Task 2

---

## Task 5: Replace concept-draft ui-refs (after Build)

**Description:**  
Simulator screenshots for Feed, Bottle (2+Custom), no title — before Gate C.

**Acceptance:**

- [ ] Real screenshots in `ui-refs/`; 01b Source updated

**Tests:** n/a (manual capture)

**Files likely touched:**  
`ui-refs/`, `01b-ui-concept.md`

**Scope:** S

**Dependencies:** Tasks 1–3 built
