# Idea day-to-day review (Gate A): watch-baby-care-home

**Result:** ok
**Round:** 1
**Updated:** 2026-09-23
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Log breast L/R, bottle ml, nap start/stop, diaper kind, pump L/R + amount in seconds on the wrist (esp. at night)
- See next feed / open nap / overdue without opening the app (face complication / Smart Stack)
- Confirm last care status after an action (and via companions)

### 2. Vital few features / problems

High-impact ~20% (most used or most painful). Sources if known: analytics, support, interviews, usability — else product judgment:

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Same section order + header / controls / footer chrome as web | Muscle memory; one-thumb path at 3AM |
| Large timed + ml + diaper chips (idle / running / Done) | Actual logging action — if chips fail, product fails |
| One primary companion signal + tap-to-section | Glance without opening app; reduces wake friction |
| Shared status model (app + widgets) | Wrong signal on face destroys trust |

### 3. Core actions visually dominant

Primary tasks need: clear placement, strong hierarchy, descriptive labels, fewer steps, helpful defaults, immediate feedback. Secondary actions → menus, overflow, expand, modal, or less prominent areas.

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Care section controls (large chips) for the section in view — act now |
| Important info / action #2 (always visible) | Header next/overdue (in-app) / primary companion signal (face / stack) |
| Secondary / deferred (expand / modal / menu / overflow) | Custom ml / Custom time / More; auth Connect stub; Poop/Mixed detail optional/skipped |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

Fix confusion that hits most users before polish (nav, forms, hidden errors, etc.):

| Problem | Fix first? | Note |
|---------|------------|------|
| Tiny / hard-to-hit chips at night | yes | Idea already requires ~44pt hits |
| Footer stacking tip + recovery | yes | Explicitly forbidden — one slot |
| Companion look ≠ app (second product) | yes | Same teal clean-minimal |
| Reordered sections vs web | yes | Fixed order stated |
| Deep link to wrong section | yes | Must land on matching care job |

### 5. Simplify the interface

Rarely used options removed or hidden so they do not distract from common tasks:

| Pass? | Note |
|-------|------|
| yes | Growth, vaccines, Insights, Telegram, Settings, guidelines out of scope; companions glance-only (no grids) |

### 6. Top user journeys

Most common workflow mapped and prioritized over rare screens:

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Raise wrist → glance companion → tap section (or open app) → Crown scroll → tap chip → haptic + Done → wrist down | yes |

### 7. Sensible defaults

Preselect what most users choose (forms, filters, checkout-like flows):

| Default | Why it helps most users |
|---------|-------------------------|
| Sample status with next-feed / open-nap / last-care | Previews and UI-first demos work without API |
| Companion priority: nap → overdue → next feed → last care | Matches “what do I need now?” |
| Wet/Dry instant save; Poop/Mixed kind-only MVP | Fewer taps when half-asleep |
| Auth stub, not real session | Does not block logging UI |

### 8. Test, measure, repeat (plan)

What to track after ship (completion, errors, abandonment, conversion, time on task) — or N/A if too early:

- Time from raise wrist → successful log (target: seconds)
- Companion tap → correct section open rate
- Pending recovery / discard rate (save confirm failures)
- Which care sections used most on Watch vs web

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | Clear vital few; secondary deferred |
| Convenience (few steps, low friction in daily use) | yes | Companion glance + chip tap path |
| Easy to use (clear actions, low learning cost) | yes | Same jobs as web; large chips |
| Understanding (problem + outcome make sense to a real user) | yes | 3AM parent logging is clear |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Watch-first; stack columns on narrow faces |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | Header → controls → one footer |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Bottle/pump ml chip set still open | Resolve in Design from web defaults (e.g. 60/90/120/150/180) |
| Enhancement | Always-on muted styling marked “if easy” | Keep as optional after core UI |
| Nit | Deep-link scheme not named yet | Fine for Design (`mybaby://home?section=…`) |

## Fix ask for Ideation

Concrete updates to `01-idea.md` (section + what to change):

1. (none — Result ok)

## Auto-approve?

- **Yes** if Result is **ok** (all Critical/Major cleared; **80/20 overall pass**; day-to-day checklist acceptable) → parent checks **Gate A**.
- **No** if **needs update** or **escalate**. Missing main goals, vital few, #1/#2 core actions, or a cluttered primary UI → **needs update** (not ok).

## Round notes

- Round 1: main-thread fallback — usage limit on Gate A Task. Result **ok**; no Critical/Major; 80/20 pass.
