# Gate A — Day-to-day + 80/20 review: phone-m2-care-home

## Result

**ok**

## Role stance

Caregiver reviewing whether Phone care home would work for daily logging after Connect.

## Day-to-day checklist

| Check | Pass? | Note |
|-------|-------|------|
| Convenience | yes | Chips on home after Connect; no extra navigate to log |
| Easy to use | yes | Same actions as Watch/web quick-care |
| Understanding | yes | Offline vs Cloud already settled in M1; care labels familiar |
| Mobile usability | yes | iPhone larger hit targets; Design must keep chips ≥44pt |
| Eye reading flow | yes | #1 chips + #2 timer/nap state; Settings secondary |

## 80/20 UI review

### 1. Main user goals

Match idea: breast timers, bottle, sleep toggle, diaper, pump, fail/retry.

### 2. Vital few

Chips + running/open state + fail/retry + last-care glance — correct 20%.

### 3. Core actions visually dominant

- **#1** care chips always visible — required
- **#2** timer / open nap always visible — required
- Secondary: dirty detail, Settings — OK in sheet/gear

### 4. Biggest usability problems first

Placeholder home and silent fail are correctly listed first.

### 5. Simplify

Do not add Insights/Growth in M2. One care home surface is enough.

### 6. Top user journeys

Open → log breast → success/update — clear primary journey.

### 7. Sensible defaults

Land on Feed; reuse bottle presets; retry same id — sound.

### 8. Test, measure, repeat

Metric (one of each care path + retry) is enough for M2.

## 80/20 overall pass?

**yes**

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | Nav shape (TabView vs scroll) open | Leave for Design Decision |
| Nit | Last care page vs strip open | Leave for Design |

## Fix ask for Ideation

1. (none — Result ok)

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable → parent checks **Gate A**.

## Round notes

- main-thread fallback — Ideation + Gate A — usage limit after Task retry
