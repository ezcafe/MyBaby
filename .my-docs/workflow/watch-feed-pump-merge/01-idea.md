# Idea: Merge Bottle + Pump amount; scrollable care pages

## Problem

Watch care home currently splits **Feed** vs **Bottle** and **Pump** vs **Pump amount** across separate horizontal swipe pages. Caregivers must swipe extra times to finish one job (breast then bottle, or pump timers then ml). Merged content also risks clipping on small faces because pages are not vertically scrollable.

## User / audience

Parents / caregivers logging feed, bottle, and pump on Apple Watch with one thumb, often at night.

## Outcome

- **Feed page** shows breast L/R **and** bottle ml chips (+ Custom) on one page.
- **Pump page** shows pump L/R/Both **and** pump ml chips (+ Custom) on one page.
- Those pages (at least Feed and Pump) scroll **up/down** so all controls stay reachable.
- Separate **Bottle** and **Pump amount** swipe pages are removed from the home strip.
- Deep links / widgets that pointed at bottle or pump-amount land on the merged Feed or Pump page.

## Metric

One swipe less for the common “feed then bottle” and “pump then amount” journeys; on a small watch face, Crown/finger scroll reaches bottle ml and pump ml without leaving the page.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** no — layout merge + scroll changes two primary pages; Gate A2 needs real-chrome refs for Feed and Pump.
- **Copy/token-only?** no

## Project shape (scan)

MyBaby Watch is a watchOS care home: horizontal `TabView` pages (Feed, Bottle, Sleep, Diaper, Pump, Pump amount, Last care) with chips/grids and sample status until GraphQL. Shared deep links/widgets live in `BabyCareShared`. README maps web Breast/Bottle/Pump sections to those separate Watch pages today.

## 80/20 UI (day-to-day)

### Main user goals

- Start/stop breast feed quickly.
- Log a bottle amount in the same visit when needed.
- Start/stop pump sides, then log pump ml without an extra swipe.
- Reach all controls on small faces via vertical scroll.

### Vital few (high-impact ~20%)

- Merge Bottle controls onto Feed.
- Merge Pump amount onto Pump.
- Vertical scroll on those denser pages.
- Keep one footer slot and existing care tap rules (no new product rules in this pass).

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Feed — breast L/R (or running timer); Pump — L/R/Both timers.
- **Important info / action #2 (always visible after short scroll if needed):** Bottle ml chips + Custom on Feed; Pump ml chips + Custom on Pump.
- **Core action placement:** Single page header → timed chips → amount grid → one footer; Digital Crown / finger scroll for overflow; remove Bottle and Pump amount from the horizontal strip.
- **Secondary actions:** Custom ml sheet (keep); Last care / Sleep / Diaper stay separate pages.

### Top user journey to optimize

Open Watch → land on Feed → breast and/or bottle → (optional) swipe to Sleep/Diaper → Pump timers + amount → Last care.

### Sensible defaults

- Keep current ml chip set / Custom picker behavior.
- Deep link `bottle` → Feed; `pump-amount` → Pump (compat aliases).
- Page order after merge: Feed → Sleep → Diaper → Pump → Last care.

### Biggest usability risks to fix first

- Crowded Feed/Pump clipping without scroll.
- Accidental horizontal swipe while scrolling vertically.
- Footer/tips fighting for space with tall control stacks.
- Broken deep links / widget taps after removing pages.

## Non-goals

- New care side-effect rules or GraphQL wiring.
- Redesign Sleep / Diaper / Last care beyond deep-link / mount fallout.
- Changing web (my-apps) home layout.
- New auth / API features.

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| Users prefer fewer swipes over separate Bottle/Pump amount pages | Yes for this ask | Gate A day-to-day review | Keep split pages; only add scroll |
| Vertical ScrollView inside page-style TabView is usable on Watch | Yes | Prototype / prior watch-baby-care-home notes | Collapse secondary into sheet instead of scroll |
| `bottle` / `pump-amount` deep links should alias to merged pages | Likely | Check widgets + README | Drop aliases; update all callers |
| Sleep / Diaper do not need scroll in this pass | Likely | Visual check after merge | Extend scroll to all care pages |

## What we should not build

- New chip types, tip copy systems, or widget redesign beyond page-target fixes.
- Persistence / server sync for this UI merge.

## Success criteria

- [ ] No standalone Bottle or Pump amount pages in the TabView strip.
- [ ] Feed shows breast + bottle ml (+ Custom); Pump shows timers + pump ml (+ Custom).
- [ ] Feed and Pump scroll vertically so clipped controls are reachable.
- [ ] Deep links and tests updated; README page map matches.
- [ ] Existing care tap / side-effect behavior unchanged.

## Open questions

- Should Sleep / Diaper / Last care also become scrollable for consistency, or only Feed + Pump?
- Keep deep-link query values `bottle` / `pump-amount` as aliases, or remove them after a short compat window?
- One shared footer tip on merged pages (feed tip vs bottle tip) — which wins when both matter?
