# Analysis: Watch care UI polish

**Size:** Prefer bullets. ≤5 solution pieces.

## Deep dive (required)

### Overall

#### What is this?
Polish pass on existing Watch care pages: quieter tips/subtitles, cleaner active timer chrome, mutual-stop parity with my-apps, 3-row Custom ml wheel, tighter centered Diaper tiles, log taps clear timer active UI.

#### Why do we need this?
After Feed/Bottle split, tips and “Tap to stop” still crowd primary controls; log taps leave stopped timers in accent/Done state, which feels still “active.” Custom wheel and Diaper spacing hurt one-handed use.

#### How to do this?
Adjust `CareControls` / `CustomMlPicker` typography + layout; tighten `TimedCareChip` running title; ensure model stop-from-log sets **idle** (not Done flash) for stopped related timers; confirm breast L↔R switch + CareSideEffects match my-apps plan.
- **Other ways:** Redesign chip chrome / new type ramp — out of scope.
- **Best practices:** Reuse `CareSideEffects` + my-apps `planBabyQuickCare` localAfter; Watch Semantic fonts where possible; constrain wheel height for ~3 rows.
- **Has API:** no
- **Has DB:** no

### Solution pieces

#### 1. Typography (tips + Tap to start)

##### What is this?
Section detail, footer tips, and idle subtitle currently use `.caption2`.

##### Why do we need this?
User wants subtler secondary copy (e.g. bottle tip, feed tip, “Tap to start”).

##### How to do this?
- Approach: Introduce one shared secondary style (e.g. `.system(size: 11)` or scale `caption2` down) on `CareSectionHeader` detail, `CareFooterSlot` tip/fail lines, and idle subtitle in `TimedCareChip`. Keep headline/primary chip titles.
- Other ways: Dynamic Type only — already at caption2 floor.
- Best practices: One token, not scattered magic sizes.

#### 2. Active timer copy

##### What is this?
Running title is `"Left - Tap to stop"` (etc.); subtitle is the timer.

##### Why do we need this?
“Tap to stop” clutters active state; idle “Tap to start” should be smaller.

##### How to do this?
- Approach: Running title = side label only (e.g. `"Left"` / `"Nap"`); drop “Tap to stop”. Idle subtitle stays “Tap to start” at smaller secondary font.
- Other ways: Move stop hint to accessibility only — fine if title is clean.

#### 3. Mutual stop + log clears active UI

##### What is this?
`CareSideEffects` already ends open nap / stops breast for non-pump log/timer actions. `stopBreastNow` / `endOpenNapNow` set `.done` (accent) for ~2s. Breast L/R can both run — my-apps switches sides (clear + start).

##### Why do we need this?
my-apps: related actions stop each other. User: log buttons (not timer) should **hide** active state — Done flash on the *stopped* timer reads as still active.

##### How to do this?
- Approach: (a) On side-effect stop from bottle/diaper/sleep/breast-start paths that clear another timer → set related phase to **`.idle` immediately** (no Done). Done flash remains only when user stops that timer themselves. (b) Breast L↔R: starting one stops the other (idle or clear) then start — mirror plan switch. (c) Keep pump independent.
- Other ways: Keep Done flash like web — **rejected** by this ask for log taps.
- Best practices: Pure flags in Shared; model owns phase transitions; unit tests for log→idle and L↔R.

#### 4. Custom ml picker — 3 rows

##### What is this?
`CustomMlPicker` uses `.wheel` with no height constraint (often ~1–2 obvious rows on Watch).

##### Why do we need this?
User wants **3** visible picker rows.

##### How to do this?
- Approach: Fix `Picker` frame height ≈ 3 × row (~68–90pt on Watch; tune in Build). Keep stride 30…240 by 10.
- Other ways: List picker — worse for ml.

#### 5. Diaper layout

##### What is this?
`DiaperKindGrid` VStack spacing 4; content not explicitly centered as a unit.

##### Why do we need this?
Icon + text should be centered; tighter gap.

##### How to do this?
- Approach: `VStack(spacing: 1 or 2)` + `.frame(maxWidth: .infinity, minHeight: …, alignment: .center)` (and center multiline if any).
- Other ways: HStack icon|text — worse on small tiles.

## Reusable patterns

| Pattern | Where | Reuse |
|---------|--------|--------|
| CareSideEffects flags | BabyCareShared | Extend callers only; keep pump = none |
| planBabyQuickCare localAfter | my-apps lib | Source of truth for stop matrix + L↔R switch |
| TimedChipPhase idle/running/done | Watch model | Done = self-stop only; side-effect → idle |
| caption2 secondary | CareControls | Replace with shared smaller secondary |

## System shape candidates

- **A (recommended):** UI tweaks in CareControls/CarePages + model stop→idle + breast switch; Shared flags unchanged unless tests need a `showDoneOnStop` distinction (prefer keep flags; model decides phase).
- **B:** New UI state machine — overkill.

## Spike notes

| Question | Finding |
|----------|---------|
| Does selectBottle already call CareSideEffects? | Yes — then Done on breast if stopped |
| Gap vs ask | Done accent after log stop; possible dual breast running |
| Wheel 3 rows API? | No API — frame height |

## Open questions

- None blocking. Assumption: “hide active state” on log = related timers → **idle**, not Done flash (web differs slightly; honor Watch ask).

## Has API / Has DB

- **Has API:** no
- **Has DB:** no
