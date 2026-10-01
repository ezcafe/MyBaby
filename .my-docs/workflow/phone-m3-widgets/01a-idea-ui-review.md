# Gate A — Day-to-day + 80/20 review: phone-m3-widgets

## Result

**ok**

## Role stance

Parent reviewing whether an iPhone Home Screen Baby Care widget would work for daily glances between logs.

## Day-to-day checklist

| Check | Pass? | Note |
|-------|-------|------|
| Convenience | yes | Glance without opening app; tap only when need to log |
| Easy to use | yes | Same meaning as Watch companions (timer / last care / color) |
| Understanding | yes | Auto vs Care type matches Watch mental model |
| Mobile usability | yes | Small + medium Home Screen; Edit for Care type is secondary |
| Eye reading flow | yes | #1 primary value + #2 color/kind cue |

## 80/20 UI review

### 1. Main user goals

Match idea: live timer, last-care age, in/out-of-range color, tap to care page.

### 2. Vital few

Timer vs last-care + color + Auto default — correct 20%. Care type Edit is secondary.

### 3. Core actions visually dominant

- **#1** primary value (timer or last-care time) always visible — required
- **#2** kind cue / teal-red always visible — required
- Secondary: Care type picker in widget Edit; logging in app — OK

### 4. Biggest usability problems first

Stub emoji, stale reload kind, running timer hidden — correctly listed first.

### 5. Simplify

No Live Activity / Control Widget / M4 in this pass — good.

### 6. Top user journeys

Start timer in Phone → Home Screen glance → live timer — clear primary journey.

### 7. Sensible defaults

Auto Care type; small+medium; `.timer`; sample fallback — sound.

### 8. Test, measure, repeat

Metric (live timer + idle color + empty suite + build) is enough for M3.

## 80/20 overall pass?

**yes**

## Findings

| Severity | Finding | Suggestion for 01-idea.md |
|----------|---------|---------------------------|
| Enhancement | systemLarge optional | Leave Open Q for Design |
| Nit | Shared views vs Phone-only layouts | Leave Open Q for Design |

## Fix ask for Ideation

1. (none — Result ok)

## Auto-approve?

- **Yes** — Result **ok**; 80/20 pass; checklist acceptable → parent checks **Gate A**.

## Round notes

- main-thread fallback — Gate A — usage limit after Task retry
