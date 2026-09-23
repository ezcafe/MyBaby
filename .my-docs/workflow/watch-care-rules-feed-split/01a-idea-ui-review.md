# Idea day-to-day review (Gate A): watch-care-rules-feed-split

**Result:** ok
**Round:** 1
**Updated:** 2026-09-23
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Start or stop a breast feed on Watch without thinking about nap state
- Log a bottle amount in one tap
- Start / end nap; log diaper; pump when needed
- Trust that open nap ends when feeding starts (same as phone)

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Auto-end open nap on feed / bottle / diaper | Night mistake: leave nap running while feeding — wrong history |
| Separate Feed vs Bottle pages | Small screen; two jobs on one page causes miss-taps |
| Quieter section subtle text | Hints must not compete with big chips |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Care chips on the current page (breast L/R, bottle ml, nap, etc.) |
| Important info / action #2 (always visible) | Section lead + next/when detail |
| Secondary / deferred (expand / modal / menu / overflow) | Custom ml sheet; Last care; auth stub |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Nap stays open when Feed/Bottle used | yes | Must match phone |
| Feed+Bottle stacked on one page | yes | Split pages |
| Subtle copy too loud | yes | Smaller font |
| Extra swipe after split | n/a | Acceptable trade for clarity |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | One job per page after split; no new rare controls |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Open → Feed or Bottle → one tap → nap ends if open → Done flash | yes |
| Open → Sleep → start/stop nap | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Land on Feed (breast) | Most common night action |
| Idle bottle chips not pre-highlighted | Avoid false “already logged” |

### 8. Test, measure, repeat (plan)

- Unit matrix: nap + feed/bottle/diaper/pump outcomes
- Manual: swipe Feed then Bottle; check subtle font

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | |
| Convenience (few steps, low friction in daily use) | yes | One-tap still |
| Easy to use (clear actions, low learning cost) | yes | Same chips, clearer pages |
| Understanding (problem + outcome make sense to a real user) | yes | |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Watch one-thumb |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | Lead then quieter subtle |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Extra swipe after split | Keep Feed→Bottle order; document in Outcome (already) |
| Nit | Open question on `.caption2` | Fine to resolve in Design |

## Fix ask for Ideation

Concrete updates to `01-idea.md` (section + what to change):

1. None — Result ok

## Auto-approve?

- **Yes** if Result is **ok** (all Critical/Major cleared; **80/20 overall pass**; day-to-day checklist acceptable) → parent checks **Gate A**.

## Round notes

- Main-thread fallback — usage limit (Gate A Task)
