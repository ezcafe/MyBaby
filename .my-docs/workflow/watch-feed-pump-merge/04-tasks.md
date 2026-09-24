# Tasks: Watch Feed/Pump page merge + scroll

## Task 1: Shrink BabyHomePage + deep-link aliases (TDD)

**Description:**
Remove `.bottle` and `.pumpAmount` cases. Remumber to feed, sleep, diaper, pump, lastCare. Map `bottle` → feed and `pump-amount` → pump in `fromQuery`. Keep `queryValue` canonical names.

**Acceptance:**

- [x] `BabyHomePage.allCases` count is 5 with expected raw values
- [x] `fromQuery("bottle") == .feed` and `fromQuery("pump-amount") == .pump`
- [x] `shouldMount` neighbors correct for new order

**Tests (TDD — what turns red first):**

- [x] Update `pageOrderIsFeedBottleSleepDiaperPumpPumpAmountLastCare` → five-page order
- [x] Update mount tests (feed neighbors sleep; pump neighbors diaper + lastCare)
- [x] Update `deepLinkPumpAmountMaps` / bottle deep-link tests to expect `.feed` / `.pump`

**Files likely touched:**
`BabyCareShared/BabyHomePage.swift`, `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift`

**Scope:** S

**Dependencies:** none

---

## Task 2: Merge Feed + Pump page UI with ScrollView

**Description:**
Compose bottle ml into `FeedPage` and pump ml into `PumpPage` inside `ScrollView`. Remove `BottlePage` / `PumpAmountPage`. Drop TabView slots for removed pages. Footer tips per design (no “Swipe for amounts.”).

**Acceptance:**

- [x] TabView has five pages only
- [x] Feed shows breast + bottle grid + Custom sheet
- [x] Pump shows L/R/Both + ml grid + Custom sheet
- [x] Both pages scroll vertically

**Tests (TDD — what turns red first):**

- [x] Keep model tests for `selectBottle` / `selectPump` / side effects green (no behavior change)
- [x] If any UI snapshot/tests reference Bottle/PumpAmount pages, remove or retarget

**Files likely touched:**
`CarePages.swift`, `BabyHomeView.swift`, `CareControls.swift` (only if footer/layout helpers needed)

**Scope:** M

**Dependencies:** Task 1

---

## Task 3: README + widget/deep-link fallout

**Description:**
Update README page map and deep-link list. Grep for `.bottle` / `.pumpAmount` page usage in widgets/shared; fix any remaining page references (not CareSideEffects action cases).

**Acceptance:**

- [x] README matches five-page strip + aliases
- [x] No code navigates to removed page cases

**Tests (TDD — what turns red first):**

- [x] Primary-signal deep-link tests still pass
- [x] Add/adjust alias assertions if missing

**Files likely touched:**
`README.md`, widget/shared files if needed

**Scope:** S

**Dependencies:** Task 1

---

## Task 4: Replace ui-refs with Watch screenshots

**Description:**
After UI works, capture Watch simulator Feed (top + scrolled) and Pump screenshots into `ui-refs/`; note in 01b.

**Acceptance:**

- [ ] Real Watch chrome images present for Feed and Pump merged pages

**Tests (TDD — what turns red first):**

- [ ] N/A (artifact only)

**Files likely touched:**
`.my-docs/workflow/watch-feed-pump-merge/ui-refs/`, `01b-ui-concept.md`

**Scope:** S

**Dependencies:** Task 2

**Status:** deferred — optional before Gate C / merge

---

## Checkpoints

After every 2–3 tasks:

- [ ] Focused tests pass
- [ ] Slice works end-to-end where applicable

## Security / UI checks

- [ ] Deep-link switch stays closed (known query values only)
- [ ] Chip hit targets unchanged; scroll reaches Custom on small face
- [ ] Horizontal page swipe still works with vertical scroll
