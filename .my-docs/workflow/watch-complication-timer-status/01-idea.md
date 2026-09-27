# Idea: Watch complications — live timer + last-care range color

## Problem

Watch face and Smart Stack complications for MyBaby do not stay honest while a care timer runs: they freeze a formatted string until the next WidgetKit rebuild (~1 min while napping). Breast / pump timers that run only in the app are not written into the App Group mailbox, so the face can show “next feed” or last care while a timer is active on the wrist. When idle, the face does not clearly show **when** the last care happened, or use color to say “still OK” vs “past recommendation.”

## User / audience

Parents and co-caregivers glancing at the Apple Watch face or Smart Stack between care jobs — often one-handed, low light, without opening the app.

## Outcome

All shipped Baby Care complication families (circular, corner, rectangular, inline — same widget kind for face + Smart Stack) show:

1. **Timer running** — live elapsed time for the active care timer (nap, breast, or pump), using system `Text(date, style: .timer)` (not a custom widget Timer / 1 Hz TimelineView).
2. **No timer** — last logged care event time; **teal / normal** if still within recommendation range; **red** if out of range (overdue / past recommendation).

Tap still deep-links into the matching care page. App still owns freshness via App Group; widgets stay read-only.

## Metric

With a nap (or breast/pump) timer running in the Watch app, raise the wrist: the complication shows a live counting timer within one second of wall time (system date style). With no timer and last feed overdue, the same complication shows last-care time in red; when still in range, teal/normal.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** yes — one primary surface (complications) with state variants; 1–2 HTML boards covering families + timer / in-range / out-of-range
- **Copy/token-only?** no — color + live timer layout change

## 80/20 UI (day-to-day)

### Main user goals

- Know if a care timer is running without opening the app
- See how long since last care when idle
- Tell at a glance whether that last care is still OK or overdue (color)

### Vital few (high-impact ~20%)

- Live timer when any care timer is running
- Last-care time + in/out-of-range color when idle
- Same meaning on every accessory family (circular / corner / rectangular / inline)

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Primary value — live `.timer` text while running; last-care relative/clock time when idle
- **Important info / action #2 (always visible):** State cue — timer kind icon/label while running; teal vs red for in-range vs out-of-range when idle
- **Core action placement:** Compact accessory layouts; rectangular may add one secondary line; tap opens deep link
- **Secondary actions:** Full status rows and logging stay in the app; no edit on the face

### Top user journey to optimize

Start timer in app → lower wrist → raise wrist → see live timer on face → later stop timer → face shows last care + color → tap complication only if they need to log

### Sensible defaults

- **Running timers that count:** nap, breast L/R, pump L/R/Both (any `TimedChipPhase.running` or open nap). If several could run, prefer one primary: open nap first, else breast, else pump (Design may refine).
- **Idle primary:** most recent care event among feed / nap / diaper / pump (by time); color from existing overdue / recommendation signals (feed/diaper overdue → red; else teal/normal).
- Live display via `Text(startedAt, style: .timer)`; keep App Group write on timer start/stop (extend DTO beyond nap-only).
- No network from the widget process.

### Biggest usability risks to fix first

- Face shows next-feed / last care while breast or pump timer is running (stale mailbox)
- Static timer string vs live `.timer` (looks broken after 30–60s)
- Red vs teal hard to read on Always On / small circular slots
- Unclear which “last care” won when multiple types exist

## Non-goals

- APNs / silent push / server-driven face refresh
- New GraphQL endpoints or DB schema
- Changing in-app chip timer UI (except writing running state to App Group for widgets)
- New complication families beyond current accessory set
- Web Baby Care UI changes

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| `Text(date, style: .timer)` works on all accessory families on watchOS 10+ | Yes for live face | Spike in Analyze / sample HTML + unit of DTO | Fall back to ~1 min timeline rebuilds for that family |
| Breast/pump running start times can be stored in App Group without tokens | Yes | Extend DTO + persist on toggle | Face only shows open nap until those fields exist |
| Existing overdue seconds / CareGuide intervals are enough for red vs teal | Prefer yes | Map idle color to feed/diaper overdue (and last-event age if needed) | Add explicit “last event at” + interval fields |
| One primary timer is enough when multiple could run | Prefer yes | Product default priority | Show “Timers” + open app, or multi-line rectangular only |

## What we should not build

- Custom `Timer` / periodic TimelineView inside the widget extension
- Per-second WidgetKit timeline entries
- Separate widget kinds per family (keep one `BabyCareComplication` kind)

## Success criteria

- [ ] All four accessory families show live `.timer` while a supported care timer is running
- [ ] Starting breast/pump/nap updates the face without waiting for a GraphQL refresh
- [ ] Idle: last care time visible; teal/normal in range; red out of range
- [ ] Deep links still open the matching page
- [ ] Empty / sample fallback still safe when App Group is empty
- [ ] Unit tests cover signal priority (timer vs idle), color band, and DTO round-trip for running timers

## Open questions

- Exact priority if nap + breast somehow both “running” (prefer: nap wins; Design confirms).
- Idle “last care” display format: relative (“25m”) vs clock time vs both on rectangular.
- Should “next feed in Xm” remain a primary idle state, or always defer to last-care time + color? **Prefer:** if overdue → red last-care (or overdue label); if in range → last-care teal (next-feed can be secondary on rectangular only).
- Red token: system `.red` vs existing care overdue tint from `CarePageBackground`.

None blocking for Gate A — defaults above are enough for day-to-day review.
