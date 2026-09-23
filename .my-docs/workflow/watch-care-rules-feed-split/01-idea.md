# Idea: Watch care rules + Feed / Bottle split

## Problem

MyBaby Watch home does not match web baby-home care side effects. Example: starting Feed (breast) or logging Bottle while a nap is running leaves the sleep timer open; on web, feed/bottle/diaper auto-end the open nap (pump does not). Feed and Bottle also share one crowded page, so breast and bottle compete on a small Watch face. Section subtle lines (e.g. “Pick an amount below”) use the same caption size as other secondary text and do not read as quieter hints.

## User / audience

Parents / caregivers logging baby care one-handed on Apple Watch (night feeds, nap checks, diaper, pump).

## Outcome

- Watch care taps follow the same rules as my-apps baby home quick-care for local timers: feed (breast start/stop or switch), bottle, and diaper end an open nap; pump L/R and pump amount do not.
- Breast-related actions still stop a running breast timer when bottle / diaper / sleep demand it; pump stays independent of breast and of nap (web parity).
- Home swipe pages: **Feed** → **Bottle** → **Sleep** → **Diaper** → **Pump** → **Last care** (Feed and Bottle are separate).
- **Bottle** and **Pump** amount rows: **2 recommended ml chips + Custom** only (not 3). Values use the same rule as my-apps baby home: `buildBabyBottleChipMls` — recent formula/pump history first, then age-band snaps (or no-birth `[60, 90, 120]`), with **`limit: 2`** for Watch space.
- Section subtle / detail under the lead uses a **smaller** font than today (e.g. below `.caption`).
- Deep links and companions still open the right page (`feed` / `bottle` distinct).
- App title: **removed** (no `Baby Care · {age}` navigation title / chrome title). Age can stay in status/copy later if needed; not in the top chrome this pass.

## Metric

Unit (and focused UI) tests prove: open nap + breast/bottle/diaper → nap ends; open nap + pump → nap stays; Feed and Bottle are separate pages; subtle detail font is smaller than section lead.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** yes — primarily page split + typography; reuse existing chip chrome
- **Copy/token-only?** no — IA + behavior change

## 80/20 UI (day-to-day)

### Main user goals

- Start / stop breast feed quickly
- Log bottle ml in one tap
- Start / end nap without fighting other care
- Log diaper; pump when needed
- See last-care status

### Vital few (high-impact ~20%)

1. Correct care side effects (especially auto-end nap on feed/bottle/diaper)
2. Separate Feed vs Bottle pages so each job fits the Watch
3. Clear quieter section hints (smaller subtle text)

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Primary care controls on the current page (breast L/R on Feed; ml chips on Bottle; nap on Sleep; etc.)
- **Important info / action #2 (always visible):** Section header lead + next/when detail when present
- **Core action placement:** One job per page; chips stay large; no new dense grids
- **Secondary actions:** Custom ml sheet; Last care page; Connect/auth stub — unchanged scope

### Top user journey to optimize

Open Watch → swipe or deep link to Feed or Bottle → one tap → open nap ends if needed → brief Done feedback → swipe away

### Sensible defaults

- Default landing page remains Feed (breast) unless a deep link / companion says otherwise
- Bottle chips keep existing ml set; no forced amount highlight when idle (web idle rule)

### Biggest usability risks to fix first

- Caregiver expects nap to stop when feeding starts (parity gap today)
- Combined Feed+Bottle page makes bottle easy to miss or rush past
- Subtle copy too loud / same size as stronger labels
- Too many ml chips on Watch (keep 2 + Custom)

## Non-goals

- Full GraphQL / `babyQuickCare` wire-up this pass (keep sample / local model; encode same **local** side-effect rules so API later matches)
- Redesign Pump / Diaper / Sleep layouts beyond shared subtle font
- New auth, widgets redesign, or iPhone app
- Changing my-apps web home itself

## Assumptions to attack

- Local Watch rules should mirror web **client + server** quick-care side effects even before API is live — yes (user asked for same rules)
- “Feed button” includes breast start (and bottle log) — yes; both end open sleep on web for non-pump actions
- Pump must **not** auto-end nap — yes (documented in `quick-care.ts` / BABY_API)
- Split pages add one more swipe — acceptable on Watch for one-job clarity

## Success criteria

- [ ] Open nap + breast start / bottle select / diaper → nap timer clears (Done flash as today)
- [ ] Open nap + pump L/R or pump ml → nap stays running
- [ ] Bottle / diaper / sleep stop a running breast timer (web `localAfter`); pump amount does not stop breast or pump timers incorrectly
- [ ] Separate Feed and Bottle pages in swipe order; deep link `page=bottle` works
- [ ] Section detail / subtle uses smaller font than section lead
- [ ] Tests cover the matrix above

## Open questions

- Exact swipe order: Feed → Bottle → Sleep… (recommended) vs Bottle after Sleep — prefer Feed→Bottle to match web row order.
- Whether breast **start** (idle→running) should end nap the same as breast **stop** / bottle — web server auto-ends open sleep for any non-pump quick action including BREAST; recommend same.
- Subtle font: `.caption2` vs custom size — prefer `.caption2` (or smaller than current `.caption` detail) to stay on system type.
- **Title:** Gate A2 — **remove** app title (Decision locked).
