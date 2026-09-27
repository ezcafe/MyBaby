# Idea day-to-day review (Gate A): watch-complication-timer-status

**Result:** ok
**Round:** 1
**Updated:** 2026-09-27
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Glance the face and know if a care timer is still running
- When idle, see how long since last care
- Tell OK vs overdue without opening the app (color)

### 2. Vital few features / problems

High-impact ~20% (most used or most painful). Sources if known: analytics, support, interviews, usability — else product judgment:

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Live timer on face while running | Raise wrist is the whole product for “is nap still going?” |
| Last-care time when idle | Answers “when did we last feed/change?” |
| Teal vs red for in/out of range | Binary glance without reading numbers |

### 3. Core actions visually dominant

Primary tasks need: clear placement, strong hierarchy, descriptive labels, fewer steps, helpful defaults, immediate feedback. Secondary actions → menus, overflow, expand, modal, or less prominent areas.

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Live `.timer` or last-care time (primary value) |
| Important info / action #2 (always visible) | Kind icon/label while running; teal vs red when idle |
| Secondary / deferred (expand / modal / menu / overflow) | Full status + logging in app; rectangular secondary line only |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

Fix confusion that hits most users before polish (nav, forms, hidden errors, etc.):

| Problem | Fix first? | Note |
|---------|------------|------|
| Face ignores breast/pump timers | yes | Must write running state to mailbox |
| Frozen timer string | yes | System `.timer` text |
| Red/teal hard on Always On | yes | Gate A2 must check contrast |
| Ambiguous “last care” winner | no | Defaults in idea OK for Design |

### 5. Simplify the interface

Rarely used options removed or hidden so they do not distract from common tasks:

| Pass? | Note |
|-------|------|
| yes | One primary value; no edit on face; one widget kind |

### 6. Top user journeys

Most common workflow mapped and prioritized over rare screens:

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Start timer in app → lower wrist → raise → see live timer | yes |
| Idle overdue → raise → see red last care → tap only if logging | yes |

### 7. Sensible defaults

Preselect what most users choose (forms, filters, checkout-like flows):

| Default | Why it helps most users |
|---------|-------------------------|
| Nap > breast > pump if multiple running | Matches current primary-signal nap-first habit |
| Idle: last event + overdue→red else teal | Matches existing overdue mental model |
| All accessory families same meaning | Face slot choice does not change rules |

### 8. Test, measure, repeat (plan)

What to track after ship (completion, errors, abandonment, conversion, time on task) — or N/A if too early:

- Manual: start nap/breast/pump → face ticks; stop → idle color; overdue sample shows red; tap deep-links

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | Vital few match raise-wrist jobs |
| Convenience (few steps, low friction in daily use) | yes | No open-app for glance |
| Easy to use (clear actions, low learning cost) | yes | Color + timer are familiar |
| Understanding (problem + outcome make sense to a real user) | yes | |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Watch face / Smart Stack |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | Value + color cue |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Idle “next feed” vs last-care still open | Keep in Open questions; Design picks |
| Nit | Red token exact shade | Gate A2 / Design |

## Fix ask for Ideation

(none — Result ok)

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable → parent checks **Gate A**.

## Round notes

- Main-thread fallback — usage limit after Task retry.
