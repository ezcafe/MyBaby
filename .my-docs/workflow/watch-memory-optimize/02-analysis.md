# Analysis: Lower MyBaby memory usage

**Size:** Prefer bullets. ≤5 solution pieces. Spike ≤5 rows.

**Has API recommendation:** no — client lifetime / SwiftUI only; no public contract change  
**Has DB recommendation:** no — sample in-memory snapshot only; no schema / persistence

## Deep dive (required)

### Overall

#### What is this?
Cut peak and steady memory for **MyBaby Watch App** (and widgets if they contribute) without changing care rules or UI look.

#### Why do we need this?
watchOS jetsams hungry apps. High memory makes the care home feel slow and risks kills during naps/timers. Skipping leaves an unexplained “heavy” app with no measured fix path.

#### How to do this?
1. Record a **baseline** (Xcode Memory Report / Instruments Allocations) on Watch — Debug vs Release noted.  
2. Apply **small, high-impact hygiene** on proven hotspots (TabView page retention, timer tick scope, uncanceled Tasks, widget overlap).  
3. Re-measure; keep behavior tests green.

- **Other ways:** Full rewrite to one page + sheets (big UX change); ignore and ship as-is (jetsam risk stays).
- **Best practices:** Apple — measure first; keep `TimelineView` local (already done); avoid wrapping whole `TabView` in periodic timelines; cancel async work; Release profile for real numbers; watchOS budgets are tight.

##### Decision 1 — How aggressive to change navigation?

###### Option 1 — Hygiene on current page TabView (recommended)
- **What it is:** Keep 7-page swipe; fix lifetime leaks, tick cost, Task cancel, widget overlap; optional lazy/offscreen page unload if Instruments proves pages stay hot.
- **Example:** Cancel done-flash `Task`s; merge duplicate widget kinds; tick only running chips (already); gate heavy work to visible page.
- **Pros:** Low UX risk; matches Gate A2 care map; small diff.
- **Cons:** May not drop as much as a one-page redesign if TabView itself is the bulk.

###### Option 2 — Collapse to fewer pages / sheets
- **What it is:** Fewer simultaneous page trees (e.g. pump amount as sheet).
- **Example:** Remove Pump amount page; open sheet from Pump.
- **Pros:** Fewer retained SwiftUI trees.
- **Cons:** Changes approved IA; out of scope for “no UI redesign”.

**Recommendation:** **Option 1** — hygiene first; only revisit IA if baseline still high after Release measure.

### Solution pieces

#### 1. Baseline + measure gate

##### What is this?
Agree how we prove “high” and “better” (target, config, process).

##### Why do we need this?
Source is tiny (~92KB Swift, no bitmap icon yet). Without a number we may chase Debug/simulator noise.

##### How to do this?
- Approach: Memory Report on **MyBaby Watch App** after launch + one nap timer run; note Debug vs Release; optionally Widgets process.
- Other ways: Guess from code only (weak).
- Best practices: Apple Instruments Allocations; compare same scenario before/after.

#### 2. Page TabView retention

##### What is this?
`BabyHomeView` declares **7** page roots in one `.page` `TabView`. Page style often keeps neighbors alive.

##### Why do we need this?
Multiple care page trees + shared `@Observable` model can keep more UI memory than one screen needs.

##### How to do this?
- Approach: Confirm with Allocations whether offscreen pages stay resident; if yes, limit work to `selectedPage` (e.g. no timer ticks when page not visible) and avoid extra state; do **not** wrap whole TabView in `TimelineView` (comment already forbids it).
- Other ways: Replace TabView (Option 2 above).
- Best practices: Existing comment in `BabyHomeView` — timer scope at chip only.

#### 3. Running-timer tick cost

##### What is this?
`TimedCareChip` uses `TimelineView(.periodic(..., by: 1))` only while `.running` — good. Continuous 1 Hz still rebuilds chip labels while nap/breast/pump runs.

##### Why do we need this?
Long naps = long tick streams; reduces transient allocations / GPU work.

##### How to do this?
- Approach: Pause ticks when app inactive / page not selected; keep 1s while visible and running; optional coarser period when elapsed ≥ 1 min (show m:ss still via local math on appear).
- Other ways: Drive subtitle from model `Date` every 1s (worse — dirties Observation).
- Best practices: Current chip-scoped TimelineView is the right pattern; keep it local.

#### 4. Done-flash Tasks

##### What is this?
`scheduleClearDone` / `scheduleClearDoneForSide` spawn uncanceled `Task { sleep 2s }` on each flash.

##### Why do we need this?
Rapid taps stack Tasks; small but needless retain of closures over the model.

##### How to do this?
- Approach: Store one `Task?` (or token) and cancel previous before scheduling; or single shared clearer.
- Other ways: `DispatchWorkItem` cancel — same idea.
- Best practices: Cancel previous work on re-entry (Swift concurrency).

#### 5. Widget bundle overlap

##### What is this?
`BabyCareWidgets` registers **two** widgets (`Complication` + `SmartStack`) with overlapping accessory families and the same provider.

##### Why do we need this?
Duplicate widget kinds can mean extra timelines / extension work for little gain.

##### How to do this?
- Approach: Prefer **one** widget configuration covering all accessory families unless Smart Stack needs a separate kind; keep timeline policy (`BabyCareWidgetTimeline`) as-is.
- Other ways: Leave dual widgets if product wants separate display names.
- Best practices: One `StaticConfiguration` per distinct kind; avoid duplicate families.

## What exists today

Watch-only care home: page `TabView` + `BabyHomeStatusModel` (`@Observable`) with sample `BabyHomeStatusSnapshot`; chip-scoped 1s `TimelineView`; widgets embed as appex. No network, no App Group store yet, no large assets. Debug agent log file exists but **no** debug HTTP/agent code remains in Swift sources.

## Dependencies

- Care side effects and flash timing must stay correct (unit tests in `MyBaby_Watch_AppTests`).
- Do not reintroduce TabView-level `TimelineView`.
- Widget deep links must keep working after any widget merge.

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `MyBaby Watch App/Views/BabyHomeView.swift` | Page TabView; no root TimelineView |
| `MyBaby Watch App/Views/Components/CareControls.swift` | Chip TimelineView |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | Done-flash Tasks; phases |
| `MyBaby Watch App/ContentView.swift` | Model lifetime (`@State`) |
| `MyBaby Watch Widgets/BabyCareWidgets.swift` | Dual widget configs |
| `BabyCareShared/BabyCareWidgetTimeline.swift` | Refresh cadence |
| `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift` | Behavior lock |

## Reusable patterns (prefer in Design)

| Pattern / name | Where it lives | Why Design should reuse it |
|----------------|----------------|----------------------------|
| Chip-scoped TimelineView | `CareControls.swift` | Isolates 1 Hz rebuilds |
| `@Observable` + `@Bindable` model | `BabyHomeStatusModel` | Fine-grained UI updates |
| Widget timeline helper | `BabyCareWidgetTimeline` | Caps refresh rate |
| Care side-effect pure flags | `CareSideEffects` | Keep logic out of views |

## System shape candidates (prefer in Design)

| Shape / concept | Where it lives | Why Design should teach it |
|-----------------|----------------|----------------------------|
| Single root model in `ContentView` | `ContentView.swift` | One lifetime owner |
| Shared framework for app + widgets | `BabyCareShared` | Avoid duplicate types |
| Appex embed | pbxproj Embed Foundation Extensions | Extension process separate from app |

## Constraints and risks

- No UI redesign / page map change unless Instruments forces it.
- Debug `-Onone` + simulator inflate memory — do not treat Debug-only numbers as ship truth.
- `ENABLE_PREVIEWS = YES` on Release Watch target — minor; disable only if measured cost.
- User has not yet supplied a peak MB number or process name.

## Settled decisions (do not relitigate)

- Has UI = no for this run (look unchanged).
- Keep chip-local timers; never wrap whole TabView in periodic TimelineView.
- Mode simple — one recommended design path (hygiene Option 1).
- **Measure (user 2026-09-23):** Xcode Debug Navigator · **MyBaby Watch App** · Debug · **Current 22.3 MB · High 22.4 · Low 2.6** · graph flat after jump (not a growing leak) · ~8 GB host (likely Simulator).
- User chose **Option 1** (hygiene; no IA collapse).

## Spike notes (optional)

| Item | Finding |
|------|---------|
| Asset weight | No PNG in AppIcon set yet; Swift sources ~92KB total |
| Debug log | `.cursor/debug-25d02e.log` shows **duplicated** page events historically — may mean double body/side effects during that session; not present in current Swift |
| Dual widgets | Both configs share provider + overlapping families |
| Timeline already scoped | Comment + code avoid TabView-wide 1s rebuild |

## Open questions (for human)

**Answered** — see Settled decisions (Debug Navigator, ~22 MB Debug Watch app, Option 1).

**Later (2026-09-23 debug):** `phys_footprint` ≈ 15–21 MB (matches Xcode). `resident_size` ~170 MB was misleading. Lazy TabView mount (±1) kept. User chose **option 3 — measure Release**; do not chase Debug lower / no IA collapse.

Are the instructions and reference files clear enough to design? **Yes** — proceed Design.
