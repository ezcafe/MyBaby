# Design: Watch care UI polish

**Mode:** simple

## Decision 1: which design approach?

### Option 1 — Model + controls polish (recommended)

**What it is:**
Keep page IA. Shrink secondary type via one shared style. Running chips drop “Tap to stop”. Side-effect stops from **log** (and related) set related timers to **idle** (hide active). Breast L↔R switch clears the other side. Custom ml wheel fixed height for ~3 rows. Diaper VStack tighter + centered.

**Example:**
`model.selectBottle(90)` while Left running → Left becomes `.idle` (not `.done`). User stops Left themselves → `.done` flash as today.

**Pros:**
- Matches Watch ask without new chrome
- Reuses CareSideEffects; small model change
- Easy unit tests

**Cons:**
- Done flash differs slightly from web when log stops a timer (intentional)

**Rejected alternative (≤3 lines):** Keep Done flash on side-effect stop (web parity) — rejected; user wants log taps to hide active state.

## System design

### Overview

- Watch-only UI + local `BabyHomeStatusModel` / Shared flags — no network.
- Secondary type token in CareControls; CustomMlPicker height; Diaper grid spacing.
- Side-effect stop → idle; self-stop → done; breast L↔R mutual exclusive.

### Concept 1 — Stop outcome

- **Self-stop** (toggle running → done): Done flash ~2s.
- **Related-stop** (flags.stopBreast / endOpenNap from another action): target → **idle** immediately.
- Breast start while other breast running: other → idle, then start this side.

## Design patterns used

### Pattern 1 — Pure flags, impure phase

**What it is:** Shared computes booleans; model maps to phases.

**Why here:** Tests stay on flags + model without UI.

**Example:** `CareSideEffects.flags(.bottle, …)` → `stopBreastNow(hideActive: true)` → `.idle`.

### Pattern 2 — Single secondary type token

**What it is:** One font helper for tips / idle subtitle / section detail.

**Why here:** Avoid scatter of magic sizes.

**Example:** `BabyCareType.secondary` used by header detail, footer tip, idle subtitle.

## Sequence

```text
User taps bottle 90 (Left running, nap open)
  → applySideEffects(.bottle)
  → endOpenNapNow → nap = idle
  → stopBreastNow → breastLeft = idle
  → bottle done flash on chip only
```

```text
User taps Left while Right running
  → applySideEffects(.breast) (may end nap)
  → stop other breast → idle
  → advance Left → running
```

## API contracts

N/A — Has API no.

## Database contracts

N/A — Has DB no.

## UI / UX / mobile

- Tips + “Tap to start”: smaller secondary (~11pt / shared token).
- Running title: side name only (no “Tap to stop”).
- Custom ml: wheel height shows ~3 rows.
- Diaper: centered icon+label, spacing 1–2.
- Hit targets unchanged (`BabyTokens.minHit`).

## OWASP

| Area | Notes |
|------|--------|
| A01 Broken access | N/A local UI |
| A03 Injection | N/A |
| Secrets | None |

## Aggressive challenges

| Challenge | Response |
|-----------|----------|
| Web shows Done on stopBreastSession | Watch ask overrides for log-related stop |
| Wheel height varies by device | Tune one constant; document in task |
| Breast both idle→start no stop needed | Switch only when other running |

## Tasks summary

See `04-tasks.md` — TDD model first, then UI.
