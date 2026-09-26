# Idea day-to-day review (Gate A): watch-ui-improvements

**Result:** ok
**Round:** 1
**Updated:** 2026-09-26
**Role:** end user (day-to-day usage) — fresh context only
**Note:** main-thread fallback — usage limit after Task retry

## 80/20 UI rule (required when UI)

### 1. Main user goals

- Log care with one tap on the right page
- Recover from a failed send without guessing which chip failed
- Log out / reconnect without swiping past Last care

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Fail chip keeps identity + Retry | Failures are rare but high-stress; unclear fail wastes time |
| Gear Settings sheet (no page 6) | Logout/reconnect is rare; should not cost a swipe page |
| Live updating cue | Network lag feels like a broken app |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Care chips with stable identity (incl. Failed subtitle) |
| Important info / action #2 (always visible) | Footer Retry when send/status fails |
| Secondary / deferred (expand / modal / menu / overflow) | Host, Log out, Reconnect in gear sheet; Advanced paste on Connect |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Title wiped to “Failed” | yes | Lose Left/90 context |
| Footer Retry unwired | yes | Dead recovery path |
| Sixth Settings page | yes | Option B sheet |
| Tiny Connect presets / 10pt type | yes | Hit + read |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Drop Settings page; session actions in sheet |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Care page → chip → fail → Retry → done | yes |
| Gear → Log out confirm → Connect → care | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Five care pages only | Common path is logging, not settings |
| Confirm before Log out | Prevents accidental disconnect |

### 8. Test, measure, repeat (plan)

- Unit: fail identity, footer retry wiring, page strip without settings
- Manual: gear sheet + confirm logout; Connect preset height

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI | yes | Vital few match idea |
| Convenience | yes | Fewer swipes; Retry visible |
| Easy to use | yes | Chip identity preserved |
| Understanding | yes | Outcome clear |
| Mobile usability | yes | Watch one-thumb |
| Eye reading flow | yes | Header → chips → footer |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Nit | Live widgets optional | Keep as Open question / defer OK |

## Fix ask for Ideation

(none — Result ok)

## Result

**ok** — Gate A auto-approve.
