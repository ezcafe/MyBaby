# Idea day-to-day review (Gate A): watch-feed-pump-merge

**Result:** ok
**Round:** 1
**Updated:** 2026-09-24
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Log breast feed and/or bottle in one visit without extra swipes
- Run pump timers and log pump ml on the same page
- Reach all controls on a small watch face (scroll, not another page)

### 2. Vital few features / problems

High-impact ~20% (most used or most painful). Sources if known: analytics, support, interviews, usability — else product judgment:

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Merge Bottle onto Feed | Night feeds often mix breast + bottle; extra swipe costs |
| Merge Pump amount onto Pump | Same session: timers then ml |
| Vertical scroll on dense pages | Small face otherwise clips controls |

### 3. Core actions visually dominant

Primary tasks need: clear placement, strong hierarchy, descriptive labels, fewer steps, helpful defaults, immediate feedback. Secondary actions → menus, overflow, expand, modal, or less prominent areas.

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Timed chips (breast L/R on Feed; pump L/R/Both on Pump) above the fold |
| Important info / action #2 (always visible) | Amount chips on the same page (short Crown/finger scroll OK on Watch) |
| Secondary / deferred (expand / modal / menu / overflow) | Custom ml sheet; Sleep / Diaper / Last care stay other pages |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

Fix confusion that hits most users before polish (nav, forms, hidden errors, etc.):

| Problem | Fix first? | Note |
|---------|------------|------|
| Extra swipe for bottle / pump ml | yes | Merge pages |
| Clipped controls on small face | yes | Vertical scroll |
| Horizontal vs vertical gesture fight | yes | Design must keep page swipe reliable |
| Footer tip when both feed + bottle matter | no | Pick one tip rule in Design |

### 5. Simplify the interface

Rarely used options removed or hidden so they do not distract from common tasks:

| Pass? | Note |
|-------|------|
| yes | Removes two swipe pages; Custom stays in sheet |

### 6. Top user journeys

Most common workflow mapped and prioritized over rare screens:

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Open → Feed (breast ± bottle) → done | yes |
| Open → … → Pump (timers ± ml) → done | yes |

### 7. Sensible defaults

Preselect what most users choose (forms, filters, checkout-like flows):

| Default | Why it helps most users |
|---------|-------------------------|
| Page order Feed → Sleep → Diaper → Pump → Last care | Matches job flow; fewer stops |
| Deep link aliases bottle→Feed, pump-amount→Pump | Old widgets still land correctly |
| Keep current ml chips + Custom | No relearning |

### 8. Test, measure, repeat (plan)

What to track after ship (completion, errors, abandonment, conversion, time on task) — or N/A if too early:

- Manual: Feed and Pump reach ml chips via scroll; page swipe still works; deep links open merged pages

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | |
| Convenience (few steps, low friction in daily use) | yes | One fewer swipe per job |
| Easy to use (clear actions, low learning cost) | yes | Same chips, same pages renamed by merge |
| Understanding (problem + outcome make sense to a real user) | yes | |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Watch one-thumb; Crown scroll |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | Header → timers → amounts → footer |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Open questions (scroll-all pages? alias lifetime? footer tip) can wait for Design | Leave Open questions; resolve in Analyze/Design |
| Nit | “Always visible” for #2 may mean “same page + short scroll” on Watch | Already implied; no idea rewrite required |

## Fix ask for Ideation

Concrete updates to `01-idea.md` (section + what to change):

1. (none — Result ok)

## Auto-approve?

- **Yes** if Result is **ok** (all Critical/Major cleared; **80/20 overall pass**; day-to-day checklist acceptable) → parent checks **Gate A**.
- **No** if **needs update** or **escalate**. Missing main goals, vital few, #1/#2 core actions, or a cluttered primary UI → **needs update** (not ok).

## Round notes

- Main-thread fallback — Gate A — usage limit (Task unavailable).
- Result **ok** — parent should auto-approve Gate A and continue to Light skim.
