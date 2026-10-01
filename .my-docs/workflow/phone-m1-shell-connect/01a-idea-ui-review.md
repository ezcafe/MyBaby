# Idea day-to-day review (Gate A): phone-m1-shell-connect

**Result:** ok  
**Round:** 1  
**Updated:** 2026-09-30  
**Role:** end user (day-to-day usage) — fresh context only  
**Note:** main-thread fallback — usage limit (Tasks unavailable)

## 80/20 UI rule (required when UI)

Focus on the vital few that deliver most day-to-day value. Progressive disclosure: keep the main surface focused; hide rare options.

### 1. Main user goals

What users come to accomplish (list):

- Open the iPhone app and choose Offline or Cloud
- Start Offline without a pairing code and trust iCloud status is honest
- Pair Cloud with a short code when they want my-apps live API
- See current mode and leave back to Connect
- Not expect care chips or widgets yet (honest M1 scope)

### 2. Vital few features / problems

High-impact ~20% (most used or most painful):

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Offline \| Cloud chips (Offline default) | First decision every new user makes |
| Start Offline without pairing | Matches Offline mental model; Watch parity |
| Honest iCloud status | Avoid fake “connected” with empty/broken store |
| Cloud pair + clear fail | Daily path when using my-apps |
| Settings: mode + leave | Escape hatch; avoid mode trap |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Mode chooser — Offline \| Cloud |
| Important info / action #2 (always visible) | Start Offline / Save & connect |
| Secondary / deferred (expand / modal / menu / overflow) | Need help; Advanced paste; deep iCloud troubleshoot; Settings after connect |
| Core actions dominant? | yes |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Stub app / nowhere to connect | yes | M1 exists to fix this |
| Offline vs Cloud wording (iCloud vs my-apps) | yes | Copy must stay clear |
| Fake Offline success without iCloud | yes | Idea already locks honest status |
| Over-promising care/widgets in M1 shell | yes | Placeholder home must not look like broken care home |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Offline hides URL/pairing; care/widgets deferred; Settings basics only |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Open → Offline (default) → Start Offline → Offline shell → relaunch still Offline | yes |
| Open → Cloud → URL default → pairing code → Save & connect → live shell | yes |
| Settings → leave → Connect | yes |
| Care log / widgets | N/A — M2/M3 |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Offline selected | Matches Watch; no server required |
| Cloud URL `http://127.0.0.1:3000` | Dev-friendly; Watch parity |
| No pairing for Offline | Fewer steps |

### 8. Test, measure, repeat (plan)

- Manual: Offline start → kill app → still Offline; iCloud signed out → clear error; Cloud bad code → clear error; leave mode → Connect
- Later analytics (optional): Connect completion, Offline vs Cloud share, pairing fail rate

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI (goals → vital few → dominant core → simplify → journey → defaults) | yes | M1 scoped honestly |
| Convenience (few steps, low friction in daily use) | yes | Offline path = one tap after chips |
| Easy to use (clear actions, low learning cost) | yes | Matches Watch Connect |
| Understanding (problem + outcome make sense to a real user) | yes | Phone stub → real Connect |
| Mobile usability (usable on phone / on the go if relevant; N/A ok) | yes | Primary surface is iPhone |
| Eye reading flow (scannable top-to-bottom; clear hierarchy in the idea) | yes | |

## Findings

### Critical

- none

### Major

- none

### Enhancements (non-blocking)

- Post-connect placeholder should say care comes next so users do not think the app is broken
- Prefer Advanced paste available in M1 for Watch parity (Open question in idea — Design can lock)

## Fix ask (only if Result is needs update)

N/A — Result ok

## Gate A verdict

Day-to-day and 80/20 pass for M1 Connect-only scope. Parent may auto-approve Gate A.
