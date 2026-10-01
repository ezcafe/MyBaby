# Gate A — Day-to-day + 80/20 review: phone-widget-hig

## Result

**ok**

## Role stance

Parent reviewing whether a Phone Widget HIG pack would improve daily Home Screen glances.

## Day-to-day checklist

| Check | Pass? | Note |
|-------|-------|------|
| Convenience | yes | Fixes glance clarity without opening the app |
| Easy to use | yes | Same Care type / timer meaning; clearer empty + overdue |
| Understanding | yes | VoiceOver + non-color overdue make sense at 3am |
| Mobile usability | yes | Widget-only; no new in-app chrome |
| Eye reading flow | yes | #1 primary value + #2 kind/range cue |

## 80/20 UI review

### 1. Main user goals

Timer glance, last-care OK vs overdue, accessible meaning, tap to care — match caregiver jobs.

### 2. Vital few

Primary value, range cue without color-only, empty copy, VoiceOver — correct 20%. Lock Screen / Large correctly secondary.

### 3. Core actions visually dominant

- **#1** timer / last-care value — required
- **#2** kind + range cue — required
- Secondary: Edit Care type; optional accessory — OK

### 4. Biggest usability problems first

Cryptic “·”, color-only overdue, missing VoiceOver — right order.

### 5. Simplify

No interactive log buttons / Live Activities / network — good.

### 6. Top user journeys

Phone log → Home glance → tap only if needed — clear.

### 7. Sensible defaults

Auto Care type; small+medium required; samples for gallery only — sound.

### 8. Test, measure, repeat

Metric (VO + overdue cue + empty copy + build + unit helpers) is enough.

## 80/20 overall pass?

**yes**

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Lock Screen vs Home-only still open | Leave Open Q1 for Grill/Design |
| Nit | systemLarge optional | Leave Open Q2 for Design |

## Fix ask for Ideation

1. (none — Result ok)

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable → parent checks **Gate A**.

## Round notes

- main-thread fallback — gate-a — usage limit after retry
