# Idea day-to-day review (Gate A): watch-security-perf

**Result:** ok
**Round:** 1
**Updated:** 2026-10-01
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

### 1. Main user goals

- Connect once (Offline or Cloud) and stay connected
- Log Feed / Sleep / Diaper / Pump fast on wrist; see last care / timer
- Leave / Log out when switching
- Glance complications / Smart Stack without opening the app

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Secrets stay off complications / errors / App Group | Glance or screenshot must not leak API token |
| Care + Fail/Retry stay snappy and visible | 3am wrist taps fail if UI hides Retry or stalls |
| Leave clears live credentials | Next session must be intentional |
| Connect Offline default unchanged | Most users should not relearn Connect |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Care page actions + status / timer (or Failed + Retry) |
| Important info / action #2 (always visible) | Connect primary path when not connected |
| Secondary / deferred (expand / modal / menu / overflow) | Advanced paste URL & token; Settings leave; complication Care type config |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Hardening that adds steps every care log | yes | Must not |
| Perf fix that blanks status or removes Retry | yes | Must not |
| Hiding Failed / iCloud sign-in errors | yes | Keep visible |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Idea prefers shared-model / store fixes over redesign |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Cold start → Connect → Care page log → complication glance → Leave when switching | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Offline on Connect | Most caregivers want iCloud, no pairing |
| Advanced paste hidden | Rare power-user path |
| Complication care type Auto when unset | Glance works without extra setup |

### 8. Test, measure, repeat (plan)

- Crash-free Connect + one care log Offline and Cloud after fixes
- No token strings in App Group / Fail copy / complications (spot check / unit)
- Watch refresh / complication timeline feels no worse after coalesce / perf work

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI | yes | #1/#2 clear; secondary deferred |
| Convenience | yes | No extra daily steps proposed |
| Easy to use | yes | Keep vertical care pages + Connect hierarchy |
| Understanding | yes | Audit-then-fix is clear |
| Mobile usability | yes | Watch + complications in scope |
| Eye reading flow | yes | Vital few scannable |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Nit | Open questions on Phone shared overlap / ATS shape are fine for Analyze / Gate B | None required now |

## Fix ask for Ideation

None.

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable.

## Round notes

- End-user view: security/perf work must stay invisible on the happy path; Fail + Retry, vertical care actions, and Connect Offline default are non-negotiable on wrist.
