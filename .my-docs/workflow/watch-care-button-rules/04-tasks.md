# Tasks: Watch care button-rule parity + care UI layout

**Mode:** simple

## Task 1 — Failing tests (S)

**Acceptance:**
- Nap running → toggle → `.done` (not new `.running`).
- `flags(.sleep, napOpen: true)` → `endOpenNap == false`; stopBreast if breast running.
- Log accent contract: done-flash only (no lasting selected fill).
- Pump amount leaves breast/nap; bottle leaves pump running.
- `BabyHomePage` order includes `pumpAmount`; query `pump-amount`.
- Chip builder / sample `bottleChipMls.count == 3`.
- Starting pump Both clears L/R running (and reverse).

**TDD notes:** Red before production fixes.

## Task 2 — CareSideEffects sleep + model matrix (S)

**Acceptance:**
- Sleep flags: no `endOpenNap`; bottle/diaper/breast still end nap.
- Nap toggle stops correctly; related-stop → idle; flash-only log fields.
- `pumpBoth` phase + exclusivity with L/R; `applySideEffects(.pumpTimer)` for Both.

**TDD notes:** Green Task 1 matrix cases.

## Task 3 — Pages: pump split + amount grid (M)

**Acceptance:**
- `PumpPage`: L + R + Both only (no ml).
- `PumpAmountPage`: 3 ml + big Custom row 2; Custom sheet → `selectPump`.
- `BottlePage`: same amount grid; limit 3 chips.
- TabView + deep links updated; tips updated (`pumpTip` timers; amount tip on amount page).

**TDD notes:** Page/query/chip-count tests green.

## Task 4 — Diaper spacing + Last care copy/icons (S)

**Acceptance:**
- Diaper icon–title spacing 0 or 1.
- Last care samples/short sentences fit one row (`lineLimit(1)`).
- Feed icon present (type-aware when possible); diaper icon `leaf.fill` (or Gate B override).

**TDD notes:** Assert sample icon names + short sentence strings if stable.

## Task 5 — Smoke (S)

**Acceptance:** Watch unit tests + build green; note in `06-test-log.md`.

## Out of scope

- Network quick-care.
- Sibling Gate C merges.
- Feed/Sleep visual redesign beyond matrix.
