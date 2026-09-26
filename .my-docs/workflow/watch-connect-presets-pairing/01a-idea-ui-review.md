# Idea day-to-day review (Gate A): watch-connect-presets-pairing

**Result:** ok  
**Round:** 1  
**Updated:** 2026-09-26  
**Role:** end user (day-to-day usage) — fresh context only  
**Note:** main-thread fallback — usage limit after Task retry

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Connect the Watch to Baby API without typing a long URL or token
- Get a short code from a laptop/web screen and finish on the wrist
- Still use Local / sample when not pairing for production

### 2. Vital few features / problems

High-impact ~20% (most used or most painful). Sources if known: analytics, support, interviews, usability — else product judgment:

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Short pairing code on Watch | Removes long paste/scribble — the real daily pain |
| Web shows the code (laptop) | Without this, Watch has nothing useful to type |
| Local preset | Developer / simulator still needs one-tap host |
| Clear connected host + errors | Wrong/expired code must not feel like “app broken” |

### 3. Core actions visually dominant

Primary tasks need: clear placement, strong hierarchy, descriptive labels, fewer steps, helpful defaults, immediate feedback. Secondary actions → menus, overflow, expand, modal, or less prominent areas.

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Watch: pairing code field + Connect |
| Important info / action #2 (always visible) | Watch: Local (presets) + current host; Web: show / create Watch code |
| Secondary / deferred (expand / modal / menu / overflow) | Advanced paste URL+token; sample continue; disconnect |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

Fix confusion that hits most users before polish (nav, forms, hidden errors, etc.):

| Problem | Fix first? | Note |
|---------|------------|------|
| “Where do I get the code?” on web | yes | Must be obvious near API tokens / Watch connect |
| Expired / wrong code = vague failure | yes | Short clear error + regenerate on web |
| Local vs pairing mix-up | yes | Local labeled for simulator; pairing is primary live |
| Long paste still looks primary | yes | Demote advanced paste |

### 5. Simplify the interface

Rarely used options removed or hidden so they do not distract from common tasks:

| Pass? | Note |
|-------|------|
| yes | Code + presets first; paste secondary — matches idea |

### 6. Top user journeys

Most common workflow mapped and prioritized over rare screens:

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Laptop web → show code → Watch enter code → Connect → care home | yes |
| Watch Local → (dev token path) → Connect → sim | yes |
| Continue with sample (no code) | yes |

### 7. Sensible defaults

Preselect what most users choose (forms, filters, checkout-like flows):

| Default | Why it helps most users |
|---------|-------------------------|
| Pairing code is the primary live path | Avoids long strings on Watch |
| Local one-tap for simulator | Keeps developer path short |
| Sample always available | Offline / first open still works |
| Short-lived codes | Limits stolen-code risk |

### 8. Test, measure, repeat (plan)

What to track after ship (completion, errors, abandonment, conversion, time on task) — or N/A if too early:

- Manual: mint code on web → redeem on Watch → live status; expired code error; Local still works; sample still works

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | |
| Convenience (few steps, low friction in daily use) | yes | Short code beats paste |
| Easy to use (clear actions, low learning cost) | yes | If web code location is obvious |
| Understanding (problem + outcome make sense to a real user) | yes | |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Watch + laptop; no iPhone required |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | Code → Connect; presets secondary row |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Web mint label not locked (tokens vs Connect Watch) | Prefer “Watch pairing” near API tokens in Design; Open Q1 OK for now |
| Enhancement | Local + token still fuzzy for physical Watch | Clarify Local = simulator / LAN only in Design |

## Fix ask (if Result is needs update)

None — Result **ok**.

## Round notes

- Round 1: ok — presets + short code journey is day-to-day sound; no Critical/Major gaps.
