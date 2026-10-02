# Idea day-to-day review (Gate A): widgets-security-perf

**Result:** ok
**Round:** 1
**Updated:** 2026-10-02
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

### 1. Main user goals

- See if a care timer is running or when last care was — without opening the app
- Trust the face (real care, clear empty, or labeled preview)
- Tap to jump into the right care page when I need to act
- Not leak care times on Lock Screen / shared glance when the device is locked

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Honest empty (no fake sample as live) | Wrong trust hurts more than a blank face |
| Privacy on Lock Screen / Watch face times | Care times are personal; visible to others nearby |
| Cheap, stable refresh | Dead battery / thrashing faces break daily glance |
| Safe tap → right care page | Glance → act is the only journey that matters |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Care kind + timer or last-care age (or clear empty) |
| Important info / action #2 (always visible) | Overdue / in-range cue |
| Secondary / deferred (expand / modal / menu / overflow) | Care type edit (system Edit Widget / face Edit) |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Sample shown as live when mailbox empty | yes | False trust |
| Missing privacy redaction on some accessory lines | yes | Lock / Always On |
| Refresh thrash or stale face | yes | Battery + confusion |
| Polish / new families / Live Activities | no | Out of scope |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Pack keeps existing glance; no new chrome or buttons |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Glance face → (optional edit Care type once) → tap opens care page | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Care type Auto | One widget covers most glances |
| Empty mailbox → empty face | Honest when not connected / no data yet |
| Preview gallery → sample only | Add-widget gallery still looks real |

### 8. Test, measure, repeat (plan)

- Empty-mailbox face shows empty copy (manual Simulator + unit)
- Locked / redacted Lock Screen hides primary care times
- No token keys in App Group DTO (unit)
- Widget builds stay green

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | Trust + privacy + glance |
| Convenience (few steps, low friction in daily use) | yes | No new steps |
| Easy to use (clear actions, low learning cost) | yes | Same widget, clearer empty |
| Understanding (problem + outcome make sense to a real user) | yes | Fake sample is the pain |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Phone + Watch faces |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | #1/#2 match HIG packs |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Circular empty copy may need shorter string than Phone “No care yet” | Keep Open question; Design picks per family |

## Fix ask for Ideation

None — Result ok.

## Gate A note

- Result **ok** — parent should auto-approve Gate A and continue to Light skim
