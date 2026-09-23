# Idea: Watch care button-rule parity + care UI layout

## Problem

1. Watch care buttons may still diverge from my-apps stop / active-vs-log rules (nap self-stop bug; lasting log-chip accent).
2. Pump packs timers + ml on one page — crowded on Watch.
3. Bottle/Pump ml: only 2 chips + small Custom; want **3** recommendations + **one big Custom** on row 2.
4. Diaper: icon–title gap still a bit wide.
5. Last care: long sentences wrap; feed/diaper icons need clearer one-row status.

## User / audience

Parents using MyBaby Watch care pages (same as my-apps baby home where possible).

## Outcome

Done when:

1. Button matrix matches my-apps (stop related timers; timers show lasting active; log = flash only; nap can stop; pump independent).
2. **Pump timers** page: Pump L + R + **Both** only.
3. **Pump amount** page: 3 recommendation ml + big Custom (same layout as Bottle).
4. **Bottle** page: 3 recommendation ml + big Custom on second row.
5. **Diaper**: tighter icon–title spacing.
6. **Last care**: one-row short status lines; clear feed icon; updated diaper icon.

## Metric

Unit tests for matrix + page order + chip limit 3; manual glance confirms layout.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** yes (existing chrome; new page is pump split)
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Start/stop timers; one-tap log ml/diaper; glance last care in one row each.

### Vital few

- Correct stop/active rules.
- Usable Bottle / Pump amount (3 + Custom).
- Pump Both available like my-apps.
- Readable Last care rows.

### Core actions visually dominant

- **#1** Timer / ml / diaper controls.
- **#2** Last care one-line status.

### Biggest usability problems first

- Nap cannot stop; log chips look stuck on.
- Pump page too dense; Custom too small.
- Last care wraps off one row.

### Simplify

- Split pump; one ml grid pattern for Bottle + Pump amount.

### Top user journeys

1. Pump L / R / Both → swipe → log ml.
2. Bottle 3 chips or Custom → log (clears related timers).
3. Last care glance: icon + short line.

### Sensible defaults

- Page order: Feed → Bottle → Sleep → Diaper → **Pump** → **Pump amount** → Last care.
- Chip snaps stay history-first (`BabyBottleChipMls`, limit **3**).

### Test, measure, repeat

- Unit: matrix + pages + limit 3 + Both exclusivity.
- Smoke: build + unit.

## Non-goals

- Network / GraphQL / persistence.
- Merging sibling Gate C runs in this workflow.
- Full redesign of Feed/Sleep chrome.

## Assumptions to attack

- **Both** = my-apps `pump_both` (single pump slot; L/R/Both mutually exclusive).
- Feed Last-care icon: type-aware when known; sample bottle → `bottle.fill` (breast → `mouth.fill` when we have type).
- Diaper Last-care icon: change `toilet.fill` → `leaf.fill` (clearer on small Watch) unless Gate B picks another.
- Short Last-care copy examples: `Bottle 120 ml · 25m`, `Wet · 1h`, `Nap · 12:04`, `Pump · —`.

## Success criteria

- [ ] Matrix gaps fixed + tested.
- [ ] Pump split + Both; Bottle/Pump amount 3+Custom layout.
- [ ] Diaper tighter spacing; Last care one row + icons.
- [ ] Smoke green.

## Open questions

- Confirm diaper Last-care SF Symbol at Gate B if `leaf.fill` is wrong.
