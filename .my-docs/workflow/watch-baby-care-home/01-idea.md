# Idea: Watch Baby Care home + companions

## Problem

At 3AM a busy parent needs to log breast, bottle, nap, diaper, or pump in seconds on the wrist. Opening a phone or hunting through a dense app costs time and attention. Without Watch face / Smart Stack companions, the parent must open the app just to see “is nap open?” or “when is the next feed?”

## User / audience

Primary: parent / caregiver of an infant who already uses (or will use) Baby Care on web/phone, logging care one-handed on Apple Watch Series 5+ / watchOS 10+.

## Outcome

- In-app `BabyHomeView` matches web home **job order** and section chrome: header (when next) → controls (act) → footer (one tip or error).
- Shared `BabyHomeStatusModel` drives app + companions (sample data OK for UI-first).
- Complications (circular/corner, rectangular/modular, inline) and Smart Stack widgets (small + medium) show one primary care signal and deep-link into the matching section.
- Clean-minimal teal visual system; large tappable chips; haptics on save and timer start/stop.
- Auth stub only (“Connect iPhone / token”); README maps web → Watch and how to add companions to face / Smart Stack.

## Metric

A parent glancing at the Watch face or Smart Stack sees the same primary signal priority (open nap → overdue → next feed → last care) and can log the matching care job from the in-app home in the same section order as web without leaving the wrist.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** no — new Watch surfaces (home + several companion families); need clear visual refs for Gate A2
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Log breast L/R, bottle ml, nap start/stop, diaper kind, pump L/R + amount in seconds
- See next feed / open nap / overdue without opening the app (companions)
- Confirm last care status after an action

### Vital few (high-impact ~20%)

- Page order + three-slot chrome (header / controls / footer) matching web care jobs
- Multipage swipe: **Feed+Bottle** → Sleep → Diaper → Pump → Last care (one primary job cluster per page; Feed and Bottle share page 1)
- Large timed + ml + diaper chips with clear idle / running / Done states
- One primary companion signal + tap-to-page deep link
- Shared status model so app and widgets stay consistent

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Care page controls (chips) for the page in view — act now
- **Important info / action #2 (always visible):** Header next/overdue (or companion primary signal when on face)
- **Core action placement:** Horizontal swipe (`TabView` page style); page 1 = Feed (Breast L/R) then Bottle ml stacked vertically; then Sleep / Diaper / Pump / Last care; page dots; chips ≥ ~44pt hit height; accent for running/selected
- **Secondary actions:** Custom ml / Custom time / More; auth Connect stub; Poop/Mixed detail sheet minimal or skip for MVP

### Top user journey to optimize

Raise wrist → glance companion (nap/next feed) → tap into matching page (or open app) → swipe to job if needed → tap chip → haptic + Done flash → put wrist down

### Sensible defaults

- Sample status model with realistic next-feed / open-nap / last-care for previews
- Companion priority fixed (nap → overdue → next feed → last care)
- Wet/Dry diaper save instantly; Poop/Mixed detail optional/skipped for MVP
- Auth: UI gate stub; no real session on Watch yet

### Biggest usability risks to fix first

- Tiny or stacked controls that miss one-thumb taps at 3AM
- Footer stacking tip + recovery (forbidden — one slot only)
- Companion chrome that looks like a second product (must match teal clean-minimal)
- Reordered pages vs web care-job order (confuses muscle memory)
- Deep link landing on wrong page
- Unclear Last care placement when jobs are separate pages

## Non-goals

- Growth, vaccines, Insights charts, Telegram
- Full Settings, birthday modal, care guidelines essay
- Full feature port of phone/web beyond home logging + companions
- Real iPhone auth / session cookies on Watch
- Multi-control grids on companions (glance only)

## Assumptions to attack

- Web home section order and copy are the source of truth for Watch (no redesign of care jobs)
- UI-first with sample `BabyHomeStatusModel` is enough for this pass (no live API)
- Series 5+ / watchOS 10+ WidgetKit is sufficient for all listed companion families
- Poop/Mixed detail can be deferred without blocking MVP logging
- Auth stub does not block previewing home + companions

## Success criteria

- [ ] `BabyHomeView` multipage swipe order: Feed+Bottle → Sleep → Diaper → Pump → Last care
- [ ] Each care page: header / controls / single footer slot
- [ ] Timed chips: idle → running (mm:ss) → Done flash; ml chips + Custom; diaper 2×2
- [ ] Shared status model used by app + complications + Smart Stack
- [ ] Complication families + small/medium widgets with priority rules and deep links
- [ ] Previews light/dark for app + companions (open-nap and next-feed samples)
- [ ] README: web→Watch map + how to add face / Smart Stack companions
- [ ] Haptics on save and timer start/stop; teal token system applied

## Open questions

- Exact bottle/pump ml chip set (e.g. 60/90/120/150/180) — use common web defaults if unknown
- Whether Poop/Mixed opens a minimal sheet or saves kind-only for MVP — prefer kind-only unless web requires detail
- Deep-link URL scheme / section IDs — define in Design (e.g. `mybaby://home?section=nap`)
- Always-on Display muted styling: “if easy” — include if low cost after core UI

## Project shape (quick scan)

Fresh Xcode watchOS app target (`MyBaby Watch App`) with Hello World `ContentView` / `MyBabyApp`. No README, no existing Baby Care UI, no WidgetKit extension yet. Greenfield Watch UI + companions on an empty SwiftUI shell.
