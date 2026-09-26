# Idea day-to-day review (Gate A): watch-hig-ui

**Result:** ok
**Round:** 1
**Updated:** 2026-09-26
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

### 1. Main user goals

- Log feed / sleep / diaper / pump fast on the wrist
- Know which care page I’m on without reading fine print
- See “what’s urgent” on the face and Last care
- Connect once with a short code

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Primary care chip on first screen | Most sessions are one tap |
| Page identity (Crown + background) | Avoid wrong-page logs at 3am |
| Live face signal | Raise wrist before opening the app |
| Retry on fail | Network fails happen; must not dead-end |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Page’s primary care control(s) |
| Important info / action #2 (always visible) | Sense of place (background / primary signal) |
| Secondary / deferred (expand / modal / menu / overflow) | Bottle/Pump amount density, Need help?, Settings, Advanced connect |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Wrong nav mental model (horizontal → vertical) | yes | Backgrounds + page dots must teach |
| Dense Feed/Pump scroll | yes | Secondary into sheets |
| Sample-only complication | yes | Live shared snapshot |
| Long Connect form | yes | Code path first |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Advanced + long guide hidden; hairline chrome reduced; titles can shrink |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Raise → glance face → open / Crown → tap chip → Done | yes |
| Fail → Retry (visible) | yes |
| First-time Connect → code → Save | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Land on Feed | Most common care job |
| Keep Feed → Sleep → Diaper → Pump → Last care order | Matches web map / muscle memory of content order |
| Production origin from plist | Less typing |

### 8. Test, measure, repeat (plan)

- Time from open → successful log (sample/live)
- Complication freshness after app status load
- Connect completion without Advanced

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI | yes | Vital few clear |
| Convenience | yes | Crown + one-tap primary |
| Easy to use | yes | Secondary deferred |
| Understanding | yes | HIG alignment stated |
| Mobile usability | yes | Watch-first |
| Eye reading flow | yes | Infographic Last care |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Bottle: keep 3 chips vs Bottle sheet still open | Prefer **Breast L/R + Bottle sheet** for one-screen Fit; note in Open questions as settled for A2 |

## Fix ask for Ideation

1. (none required for ok)

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable.

## Round notes

- Main-thread fallback — gate-a — usage limit after retry
- Settled preference for UI concept: Feed keeps Breast L/R on page; Bottle amounts (3 chips + Custom) move to sheet so Feed fits one screen.
