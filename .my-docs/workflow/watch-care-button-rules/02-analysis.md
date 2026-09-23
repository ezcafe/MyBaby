# Analysis: Watch care button-rule parity + care UI layout

**Size:** Prefer bullets. ≤5 solution pieces.

## Deep dive (required)

### Overall

#### What is this?
(1) Fix my-apps button-rule gaps on Watch. (2) Split Pump into timers vs amount; Bottle/Pump amount = 3 ml + big Custom; tighten Diaper; shorten Last care rows + icons.

#### Why do we need this?
Stop/active bugs confuse logging. Dense Pump page and wrapping Last care hurt one-handed Watch use.

#### How to do this?
Keep Shared flags + model fixes from prior analysis; add `BabyHomePage.pumpAmount`, `TimedChipSide.pumpBoth`, ml grid layout, Last care copy/icons.
- **Other ways:** Keep one Pump page with scroll — rejected (user asked split).
- **Best practices:** my-apps pump L/R/Both + flash-only ml; Watch related-stop → idle.
- **Has API:** no
- **Has DB:** no

### Solution pieces

#### 1. Button matrix (unchanged from prior analyze)

##### What is this?
Nap toggle restart bug; lasting log `selected*`; sleep flags must not `endOpenNap`.

##### Why / How?
See prior matrix. Fix CareSideEffects.sleep + flash-only accent + tests.

#### 2. Pump page split + Both

##### What is this?
Today one `PumpPage` = L/R timers + ml. Need page A: L + R + Both; page B: amount only.

##### Why do we need this?
Match my-apps pump Both; free vertical space for ml layout.

##### How to do this?
- Approach: `BabyHomePage.pump` + `.pumpAmount`; TabView tags; deep link `pump` / `pump-amount`. Model `pumpBoth` phase; L/R/Both exclusive (idle others). `CareSideEffects.pumpTimer` for Both.
- Other ways: Both only on amount page — no; Both is a timer.
- Best practices: my-apps single `pumpSlot` including `pump_both`.

#### 3. Bottle + Pump amount: 3 ml + big Custom

##### What is this?
`MlChipRow` adaptive grid with Custom as peer chip; chip limit 2.

##### Why do we need this?
User: 3 recommendations; Custom full width on row 2.

##### How to do this?
- Approach: `BabyBottleChipMls` / snapshot **limit 3**. New layout: `HStack`/`LazyVGrid` 3 equal chips row 1; row 2 one full-width Custom button (taller/minHit). Reuse for Bottle + Pump amount. Flash-only accent.
- Other ways: 2×2 with Custom in cell — rejected (user wants big Custom row 2).

#### 4. Diaper spacing + Last care one-row

##### What is this?
Diaper `VStack(spacing: 2)`; Last care long sentences + `toilet.fill` diaper / feed icon present but copy wraps.

##### Why do we need this?
Fit Watch width; clearer icons.

##### How to do this?
- Approach: Diaper spacing **0–1**. Last care: `lineLimit(1)` + shorter sample sentences; feed icon keep/type-aware; diaper icon → `leaf.fill` (Gate B can swap).
- Other ways: Truncate mid-sentence with `…` only — still prefer short authored copy.

#### 5. Already OK

Stop matrix for bottle/diaper/pump independence; breast L↔R; related-stop → idle (except nap self-stop bug).

## Button matrix (truth vs Watch)

| Action | Gap? |
|--------|------|
| Nap self-stop | **Critical** — side-effect + advance restarts |
| Log chip lasting selected | **Major** — flash-only like web |
| Pump Both | **Missing** — add with split |
| Bottle/Pump 3+Custom layout | **Missing** — layout + limit 3 |
| Diaper / Last care polish | **Missing** — spacing + copy/icons |

## Reusable patterns

| Pattern | Where | Reuse |
|---------|--------|--------|
| planBabyQuickCare / pump_both | my-apps | Both exclusivity |
| CareSideEffects | Shared | sleep without endOpenNap |
| BabyBottleChipMls | Shared | limit 3 |
| Flash-only ml | my-apps selection resolver | Watch done* only |

## System shape candidates

- **A (recommended):** Extend page enum + model Both + shared MlAmountGrid; matrix fixes in same draft.
- **B:** Separate workflow for UI — slower; user asked in this Gate B pass.

## Spike notes

| Question | Finding |
|----------|---------|
| my-apps Both? | Yes `pump_both` timed chip |
| Chip limit today | 2 in samples / Watch UI |

## Open questions

- Diaper Last-care SF Symbol — default `leaf.fill` unless Gate B says otherwise.

## Has API / Has DB

- **Has API:** no
- **Has DB:** no
