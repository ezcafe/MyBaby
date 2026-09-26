# Idea day-to-day review (Gate A): watch-fail-status-settings

**Result:** ok  
**Round:** 1  
**Updated:** 2026-09-26  
**Role:** end user (day-to-day usage) — fresh context only  
**Note:** main-thread fallback — usage limit after Task retry

## 80/20 UI rule (required when UI)

### 1. Main user goals

- See that a care log failed to send without hunting for muted footer text
- Open Settings by swiping to the last page
- Log out when ending a live session or switching hosts

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Error on the trigger button that failed | Matches where attention already is after a tap |
| Settings as last page | Discoverable without remembering the gear |
| Log out clears live session | Avoids “still connected” confusion |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Care chips; on fail, error status on that chip |
| Important info / action #2 (always visible) | Settings: connection summary + Log out |
| Secondary / deferred | Advanced pairing paste; optional gear shortcut |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Fail only in muted footer | yes | Easy to miss on Watch |
| No logout | yes | Token stuck until manual overwrite |
| Settings only behind gear | yes | Last page fixes discoverability |
| Stuck error blocking taps | yes | Must clear on retry/success |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Chip fail + Settings logout; no toast/alert stack |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Log care → send fails → chip shows error → retry → success | yes |
| Swipe to Settings → Log out → reconnect/sample | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Clear chip error after successful resend | Next log stays fast |
| Logout → connect screen | Makes “logged out” obvious |
| Settings last after Last care | Care pages stay first |

### 8. Test, measure, repeat (plan)

- Manual: force live fail → chip error; Settings logout → connect again
- Unit: page order, fail→button state, token clear

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI | yes | |
| Convenience | yes | Fail where you tapped; swipe for Settings |
| Easy to use | yes | Log out labeled clearly |
| Understanding | yes | |
| Mobile usability | yes | Watch TabView |
| Eye reading flow | yes | Chip → Settings page hierarchy in idea |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Gear vs Settings-only still open | Resolve in Design; no idea rewrite |
| Enhancement | Status-load fail (no chip) path open | Footer vs page banner — Design |
| Nit | Exact chip fail copy not locked | UI concept / Design |

## Fix ask for Ideation

1. None — Result **ok**.

## Auto-approve?

- **Yes** if Result is **ok** → parent checks **Gate A**.

## Round notes

- Round 1: ok — fail-on-chip + Settings last + logout is day-to-day sound; no Critical/Major.
