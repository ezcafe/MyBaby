# Idea: watchOS HIG UI pack (MyBaby Watch)

## Problem

MyBaby already logs care with one-thumb chips, but the UI still feels iPhone-ported vs Apple watchOS 10+: horizontal page swipe (not Crown-first), flat backgrounds, dense Feed/Pump screens that scroll, custom hairline chrome, Last care as a caption list, sample-only complications, and a long Connect form. Parents at 3am need raise → sense of place → tap → done.

## User / audience

Parents (and co-caregivers) logging feed / sleep / diaper / pump on Apple Watch during short, often one-handed sessions — often in low light, Always On, or while holding a baby.

## Outcome

Watch care home and companions follow Apple HIG patterns: vertical Crown pages, meaning-bearing backgrounds, one-screen primary actions where possible, system materials, infographic Last care, live complications, short Connect, and reachable Retry / timer readability on Always On — without changing care business rules or adding new server APIs.

## Metric

A caregiver can Crown-scroll between care pages, identify the page by background at a glance, complete the top job (e.g. start nap or log bottle) without hunting secondary controls, and see a live primary signal on the face complication after a status refresh in the app.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** no — multi-surface (home pages, connect, complications); full HTML ui-refs for Gate A2
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Log the care job on the wrist in one or two taps
- Know which page / state they are on without reading a title
- See the most urgent “what next” on the face / Last care
- Connect once with a short code; rarely reopen Advanced

### Vital few (high-impact ~20%)

- Vertical page navigation + page identity (background)
- Feed / Sleep primary chips always reachable on first screen
- Live complication primary signal
- Fail → Retry without hunting

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Timed or one-shot care control for the current page (e.g. Breast L/R or Nap)
- **Important info / action #2 (always visible):** Page identity cue (background / primary signal) so they know where they are
- **Core action placement:** Large chips lower/center; Crown moves pages; secondary density (ml grids, Pump sides, help text) in sheets / disclosure
- **Secondary actions:** Bottle ml chips + Custom in sheet from Feed; Pump amount / side density collapsed similarly; Settings gear; Advanced connect + long guide behind “Need help?”; Last care secondary status rows under one large primary signal

### Top user journey to optimize

Raise wrist → glance complication (or open app on Feed) → Crown to Sleep/Diaper/… if needed → tap primary chip → haptic + Done → lower wrist

### Sensible defaults

- Landing page remains **Feed**
- Page order stays Feed → Sleep → Diaper → Pump → Last care (vertical)
- Production pairing origin from Info.plist when Production selected
- Widget shows open nap → overdue → next feed → last care priority (unchanged signal rules)

### Biggest usability risks to fix first

- Horizontal swipe habit break when moving to verticalPage — page dots + backgrounds must reorient fast
- Collapsing Bottle/Pump into sheets must not add steps for the common ml tap
- Live widgets must not show stale sample forever after connect
- Connect must not bury the pairing code behind Advanced

## Non-goals

- New GraphQL endpoints or schema / migrations
- Changing quick-care side-effect rules (feed ends nap, pump does not, etc.)
- Redesigning web Baby home
- Adding new care types or multi-baby picker
- Full Always On custom faces beyond dimming / timer legibility

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| App Group can be enabled for Watch app + widgets in this project | Yes for live widgets | Check entitlements / signing | Fall back to shared file only in app process; document widgets still sample until Group ships |
| Vertical pages + Feed-first is acceptable vs horizontal swipe | Yes for HIG | Gate A / A2 look | Keep vertical but add page labels if confusion |
| Bottle sheet does not slow the common 3-chip path | Prefer yes | UI concept + Gate A2 | Keep 3 ml chips on Feed; only Custom in sheet |
| No new public API needed for widget freshness | Prefer yes | Analyze shared store | If network-from-widget required, Has API = yes later |

## What we should not build

- A new settings TabView page (keep gear sheet)
- Horizontal `.page` style as the shipping nav
- Decorative gradients with no state meaning

## Success criteria

- [ ] TabView uses `.verticalPage`; Digital Crown changes care pages
- [ ] Each care page (and key urgency states) has distinct `containerBackground`
- [ ] Feed / Sleep / Diaper primary actions fit one screen without scroll for the common path; Bottle/Pump secondary density in sheets as designed
- [ ] Idle chips use materials / less hairline; Settings uses system destructive / primary buttons where practical
- [ ] Last care leads with one large primary signal, then short rows
- [ ] Complications read shared live snapshot (App Group); rectangular shows one primary + one secondary
- [ ] Connect: Local/Production + code + Save first; Advanced + guide behind Need help?
- [ ] Retry reachable (toolbar/footer); running timers remain readable when Always On / inactive scene

## Open questions

- Exact Feed bottle disclosure: keep top-3 ml chips on page vs all ml in sheet? Prefer: keep top-3 on page if they still fit; else single “Bottle” entry → sheet with chips + Custom.
- App Group identifier string and entitlement ownership (Watch app vs widgets) — settle in Analyze.
- Whether Pump timer L/R/Both stay on page with amounts in sheet only (recommended).
