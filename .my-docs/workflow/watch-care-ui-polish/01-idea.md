# Idea: Watch care UI polish

## Problem

Watch care pages still feel slightly loud or inconsistent after the Feed/Bottle split:

- Subtle helper text and “Tap to start” are too large.
- Active timer shows “Tap to stop” which adds clutter.
- Button mutual-stop / active-state rules do not fully match my-apps baby home (clicking a care action should stop related running actions; log taps should clear active timer UI).
- Custom ml wheel shows too few rows.
- Diaper buttons: icon + label not centered; gap between icon and text too wide.

## User / audience

Parents logging care on Apple Watch (same users as MyBaby Watch care pages).

## Outcome

Done when Watch care UI:

1. Uses **smaller** subtle/helper text (e.g. “Pick an amount below”, “About 6-8 feeds a day”).
2. Uses **smaller** “Tap to start”; **no** “Tap to stop” on active timer state (timer still shows running state without that subtitle).
3. **Mutual stop** matches my-apps baby page: tapping a care button stops related running buttons/timers (existing `CareSideEffects` parity — fix gaps if any).
4. **Custom ml picker** shows **3** visible picker rows.
5. **Diaper** buttons: icon + text **centered**; **tighter** space between icon and text.
6. Tapping **log** buttons (bottle ml, diaper, pump amount — not the timer toggle) **hides/clears** the active timer visual state (after applying stop side effects as needed).

## Metric

Unit tests cover side-effect / active-state clear on log actions; manual glance confirms typography, diaper spacing, and 3-row picker.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** yes (polish only)
- **Copy/token-only?** no (behavior + layout + typography)

## 80/20 UI (day-to-day)

### Main user goals

- Start/stop timers quickly (breast, nap, pump).
- Log bottle / diaper / pump amount in one tap.
- Read tips without crowding primary controls.

### Vital few (high-impact ~20%)

- Clear active/idle timer affordance without “Tap to stop” noise.
- Log actions clear conflicting active UI (parity with phone).
- Readable but quiet tips; usable Custom ml picker.

### Core actions visually dominant

- **#1** Timer / primary care buttons stay dominant.
- **#2** Log chips (ml / diaper) stay easy to hit.
- Tips and idle subtitles stay secondary (smaller).

### Biggest usability problems first

- Active “Tap to stop” competes with timer readout.
- Log tap leaving another action “active” confuses state.
- Wide diaper icon–label gap wastes Watch height.

### Simplify

- Drop active “Tap to stop” copy; keep visual active state only.
- Reuse CareSideEffects / my-apps rules — do not invent a second matrix.

### Top user journeys

1. Start breast → log bottle/diaper → breast stops + active UI clears.
2. Open Custom ml → pick with 3 visible rows → confirm.
3. Idle glance: smaller tip + “Tap to start”.

### Sensible defaults

- Keep Feed / Bottle / Diaper / Sleep / Pump page structure from prior split.
- Keep bottle chip limit 2 + Custom.

### Test, measure, repeat

- Unit: CareSideEffects + model active-state clear on log paths.
- Smoke: build + unit; lite e2e only if tasks require.

## Non-goals

- New pages or IA changes.
- Network / GraphQL / persistence.
- Merging sibling `watch-care-rules-feed-split` Gate C in this run.
- Redesigning care chrome beyond listed polish.

## Assumptions to attack

- “Log buttons” = bottle ml chips, Custom confirm, diaper wet/dirty, pump ml chips (not breast/nap/pump **timer** toggles).
- “Stop related buttons” = same matrix as my-apps / existing `CareSideEffects` (non-pump ends open nap; bottle/diaper/sleep stop breast; pump independent).
- Smaller text = one step down from current Watch text styles (e.g. caption2 → even smaller / footnote where available), not a full type ramp redesign.

## Success criteria

- [ ] Subtle tips and “Tap to start” are clearly smaller.
- [ ] Active timer has no “Tap to stop” string.
- [ ] Log / related actions stop related timers per my-apps rules and clear active UI.
- [ ] Custom ml wheel shows 3 rows.
- [ ] Diaper icon+text centered with tighter spacing.
- [ ] Tests + smoke green.

## Open questions

- None blocking — analyze will confirm exact SwiftUI font tokens and any CareSideEffects gaps vs my-apps.
