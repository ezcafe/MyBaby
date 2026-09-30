# Idea day-to-day review (Gate A): offline-icloud-mode

**Result:** ok  
**Round:** 2  
**Updated:** 2026-09-29  
**Role:** end user (day-to-day usage) — fresh context only  
**Note:** main-thread fallback — usage limit (Tasks unavailable)

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Run durable Offline care on Watch without Local/Production API
- Trust care survives relaunch via iCloud-backed store
- Keep Local / Production when they need the web API
- Not expect an iPhone companion in this pass (contract only)

### 2. Vital few features / problems

High-impact ~20% (most used or most painful). Sources if known: analytics, support, interviews, usability — else product judgment:

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Peer Offline chip on Connect | Clear path without host nesting |
| Durable persist (≠ sample) | Trust that care is real |
| iCloud status visible | Avoid silent empty history |
| Start Offline without pairing | Matches offline mental model |
| Leave / switch mode clearly | Avoid mode trap |

### 3. Core actions visually dominant

Primary tasks need: clear placement, strong hierarchy, descriptive labels, fewer steps, helpful defaults, immediate feedback. Secondary actions → menus, overflow, expand, modal, or less prominent areas.

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Local \| Production \| Offline mode chooser |
| Important info / action #2 (always visible) | Start Offline / Save & connect |
| Secondary / deferred (expand / modal / menu / overflow) | Help, Advanced paste, deep iCloud troubleshoot |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

Fix confusion that hits most users before polish (nav, forms, hidden errors, etc.):

| Problem | Fix first? | Note |
|---------|------------|------|
| Offline vs sample | yes | Locked in idea — copy must keep them apart |
| iCloud unavailable | yes | Status before first log |
| Over-promise companions | yes | Locked deferred — Connect/help copy must not claim iPhone this pass |

### 5. Simplify the interface

Rarely used options removed or hidden so they do not distract from common tasks:

| Pass? | Note |
|-------|------|
| yes | Offline hides URL/pairing; API help stays secondary |

### 6. Top user journeys

Most common workflow mapped and prioritized over rare screens:

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Connect → Offline → Start → log → relaunch → same data | yes |
| Connect → Local/Production → live API | yes |
| Companion on iPhone this pass | N/A — deferred by Decision 1 |

### 7. Sensible defaults

Preselect what most users choose (forms, filters, checkout-like flows):

| Default | Why it helps most users |
|---------|-------------------------|
| Offline opt-in | Keeps Local default for simulator/dev |
| No pairing for Offline | Fewer steps |
| Last-used mode | Faster return |

### 8. Test, measure, repeat (plan)

What to track after ship (completion, errors, abandonment, conversion, time on task) — or N/A if too early:

- Manual: Offline → log → kill → restore; iCloud signed out → clear error; Local/Production unchanged; docs list container for companions

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | Scope honest after Option 1 |
| Convenience (few steps, low friction in daily use) | yes | |
| Easy to use (clear actions, low learning cost) | yes | |
| Understanding (problem + outcome make sense to a real user) | yes | Watch + contract clear |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Watch; phone N/A this pass |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Sample still available beside Offline | Design should demote sample entry once Offline is stable (Open Q2) |
| Enhancement | Histories Offline vs live | Keep separate (Open Q1 default) — confirm in Design |

## Fix ask (if Result is needs update)

None — Result **ok**.

## Round notes

- Round 1: needs update — share scope + Offline≠sample + peer mode unlocked.
- Round 1 Ideation update: Decision 1 Option 1 applied in `01-idea.md`.
- Round 2: ok — locked decisions close Critical/Major gaps; 80/20 pass; auto-approve Gate A.
- main-thread fallback — usage limit (Tasks unavailable).
