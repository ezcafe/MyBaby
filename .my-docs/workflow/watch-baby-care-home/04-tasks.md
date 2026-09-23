# Tasks: Watch Baby Care multipage home + companions

## Task 1: Tokens + status model + samples

**Description:** Add color tokens, `BabyHomePage` enum, `BabyHomeStatusSnapshot` / `BabyHomeStatusModel`, sample open-nap + next-feed, pure `primarySignal` resolver. Unit-test resolver + age title formatting.

**Acceptance:**

- [ ] Light/dark teal tokens match 01b
- [ ] Samples cover open-nap and next-feed
- [ ] `primarySignal` priority: nap → overdue → next feed → last care
- [ ] Model supports timer elapsed and Done flash state

**Tests (TDD — what turns red first):**

- [ ] `primarySignal` returns nap when `openNapStartedAt` set
- [ ] Else overdue feed/diaper beats next-feed countdown
- [ ] Age title uses days when age &lt; 1 month else months

**Files likely touched:** `MyBaby Watch App/Theme/`, `Models/`, `MyBaby Watch AppTests/`

**Scope:** M

**Dependencies:** none

---

## Task 2: Care chrome + chip controls

**Description:** Reusable header / controls / footer slot; timed chip; ml chips + Custom picker stub; diaper 2×2; Done flash ~2s; haptics hooks.

**Acceptance:**

- [ ] One footer slot priority: recovery → fail → tip
- [ ] Timed idle / running / Done states
- [ ] Diaper grid Wet/Poop/Mixed/Dry; Wet/Dry instant; Poop/Mixed kind-only
- [ ] ml chips accent selected; Custom opens simple picker

**Tests (TDD — what turns red first):**

- [ ] Footer shows recovery over tip when pending set
- [ ] Timed chip state machine idle→running→done→idle

**Files likely touched:** `Views/Components/`, tests

**Scope:** M

**Dependencies:** Task 1

---

## Task 3: BabyHomeView multipage shell

**Description:** `TabView` page style: Feed+Bottle → Sleep → Diaper → Pump → Last care. Wire deep link `mybaby://home?page=`. Replace `ContentView`. Auth stub gate (bypass in preview).

**Acceptance:**

- [ ] Swipe order matches Gate A2
- [ ] Page 1 stacks Feed then Bottle
- [ ] Deep link selects correct page
- [ ] Previews light/dark with samples
- [ ] Auth stub does not block sample preview

**Tests (TDD — what turns red first):**

- [ ] URL `page=sleep` maps to `.sleep`
- [ ] Unknown page falls back safely

**Files likely touched:** `BabyHomeView.swift`, page views, `MyBabyApp.swift`, `Info.plist` URL scheme

**Scope:** M

**Dependencies:** Task 2

---

## Task 4: WidgetKit companions

**Description:** Widget Extension: circular/corner, rectangular/modular, inline complications; Smart Stack small + medium; shared snapshot + `primarySignal`; teal tint; timeline refresh ~1 min while napping / at due; tap deep-link.

**Acceptance:**

- [ ] Families listed in design ship
- [ ] Small = primary signal; medium = 2–3 last-care rows
- [ ] Previews light/dark open-nap and next-feed
- [ ] Same sample model types as app (target membership)

**Tests (TDD — what turns red first):**

- [ ] Timeline entry date uses nap tick or next due
- [ ] Deep link URL matches app page ids

**Files likely touched:** `MyBaby Watch Widgets/` (new), shared model files membership, `project.pbxproj`

**Scope:** M

**Dependencies:** Task 1, Task 3

---

## Task 5: README

**Description:** Short README: web→Watch page map; how to add face complications / Smart Stack; sample vs future API.

**Acceptance:**

- [ ] Maps Breast+Bottle → page 1 Feed+Bottle; Nap→Sleep; etc.
- [ ] Companion install steps
- [ ] Notes UI-first sample status

**Tests (TDD — what turns red first):**

- [ ] N/A (docs) — manual check

**Files likely touched:** `README.md`

**Scope:** S

**Dependencies:** Task 3, Task 4

---

## Checkpoints

After every 2–3 tasks:

- [ ] Focused tests pass
- [ ] Slice works end-to-end where applicable (Simulator home swipe + widget preview)
