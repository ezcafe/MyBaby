# Idea day-to-day review (Gate A): phone-hig-ui

**Result:** ok  
**Round:** 1  
**Updated:** 2026-10-01  
**Role:** end user (day-to-day usage) — fresh context only

## 80/20 UI rule (required when UI)

### 1. Main user goals

- Connect once (Offline or Cloud) without feeling like a developer tool
- Log feed / sleep / diaper / pump fast on the phone
- See Failed + Retry without hunting
- Open Settings / Leave only when needed

### 2. Vital few features / problems

| Vital few item | Why it is high-impact |
|----------------|------------------------|
| Parent-facing Connect + Offline primary CTA | First-run and after Leave; blocks all care |
| Phone-scale primary care chips on the selected tab | Most sessions are one or two taps |
| Clear tab labels (esp. Last care / Status) | Avoid wrong-tab logs when half-asleep |
| Fail → Retry always reachable | Network / iCloud fails happen |

### 3. Core actions visually dominant

| Item | Value |
|------|-------|
| Important info / action #1 (always visible) | Tab’s primary care control(s) |
| Important info / action #2 (always visible) | Tab bar identity + Connect primary CTA when not connected |
| Secondary / deferred (expand / modal / menu / overflow) | Bottle/Pump amounts, Need help?, Advanced paste, Settings |
| Core actions dominant? | yes — idea locks this; current app partly fails Connect copy and phone scale |

### 4. Biggest usability problems first

| Problem | Fix first? | Note |
|---------|------------|------|
| Connect “API server” + custom form | yes | Parents hesitate |
| Watch-sized care chrome on phone | yes | Hard to tap / read |
| Unclear “Last” tab label | yes | Cheap win |
| Shared changes regressing Watch | yes | Must stay in Design constraints |

### 5. Simplify the interface

| Pass? | Note |
|-------|------|
| yes | Advanced + help stay secondary; no new tabs; Form/system controls preferred |

### 6. Top user journeys

| Journey steps (Open → … → done) | Optimized? |
|---------------------------------|------------|
| Cold start → Offline Start → Feed → tap chip | yes (target) |
| Widget → matching tab → tap | yes (keep; widgets out of visual redesign) |
| Fail → Retry | yes |
| Settings → Leave → Connect again | yes |

### 7. Sensible defaults

| Default | Why it helps most users |
|---------|-------------------------|
| Offline selected on Connect | Matches product default; no code needed |
| Land on Feed | Most common care job |
| Keep five-tab order | Matches Watch/web map |

### 8. Test, measure, repeat (plan)

- Time cold start → Offline → first log
- Tab label recognition (esp. fifth tab)
- VoiceOver + larger Dynamic Type on Connect + Feed

**80/20 overall pass?** yes

## Day-to-day checklist

| Focus | Pass? | Note |
|-------|-------|------|
| 80/20 UI | yes | Vital few match caregiver jobs |
| Convenience | yes | Offline default + tab care |
| Easy to use | yes | Secondary deferred |
| Understanding | yes | HIG pack goal is clearer chrome |
| Mobile usability | yes | iPhone-first pack |
| Eye reading flow | yes | Tab → chips → footer/Retry |

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Fifth-tab name still open | Prefer settle “Status” vs “Last care” in Design; not blocking Gate A |

## Fix ask for Ideation

1. (none required for ok)

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable.

## Round notes

- Main-thread fallback — gate-a — usage limit after retry
- End-user judgment: pack correctly prioritizes Connect jargon, phone-scale care, tab clarity, Retry — without inventing new product surfaces.
