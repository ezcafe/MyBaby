# Design: Watch care button-rule parity + care UI layout

**Mode:** simple

## Decision 1: which design approach?

### Option 1 — Matrix fix + pump split + amount grid (recommended)

**What it is:**
One draft covering: (1) sleep flags / nap self-stop + flash-only log accent; (2) Pump timers page (L/R/Both) + Pump amount page; (3) Bottle & Pump amount share **3 ml + full-width Custom**; (4) Diaper tighter; (5) Last care one-line copy + feed/diaper icons.

**Example:**
Tab order … → Diaper → Pump (L|R|Both) → Pump amount (60|90|120 / Custom) → Last care (`Bottle 120 ml · 25m`).

**Pros:**
- Matches user Gate B ask in one ship
- Reuses CareSideEffects + chip builder
- Both aligns with my-apps

**Cons:**
- Larger than matrix-only scope

**Rejected alternative (≤3 lines):** Matrix-only first, UI later — rejected; user added UI in the same Gate B pass.

## System design

### Overview

- Local Watch UI + `BabyHomeStatusModel` + Shared helpers — no network.
- Pages: `feed`, `bottle`, `sleep`, `diaper`, `pump`, **`pumpAmount`**, `lastCare`.
- Stop matrix: sleep flags never `endOpenNap`; other non-pump may end nap / stop breast; pump family independent.
- Active chrome: timers lasting; log flash-only.
- Amount UI: shared grid component; chip limit 3.

### Concept 1 — Pump slot exclusivity

- One pump timer active: L, R, or Both.
- Starting one → others idle (same as breast L↔R).
- Amount log does not clear pump timer (my-apps).

### Concept 2 — Amount grid

- Row 1: three equal ml chips.
- Row 2: one big Custom (full width, minHit).
- Accent only while `doneMl` flash (~2s).

## Design patterns used

### Pattern 1 — Pure flags, impure phase

**What:** Shared booleans; model maps phases.

**Why:** Matrix unit tests without UI.

**Example:** `flags(.sleep, napOpen: true)` → `endOpenNap == false`.

### Pattern 2 — Shared amount grid

**What:** One SwiftUI view for Bottle + Pump amount.

**Why:** Same 3+Custom layout twice.

**Example:** `CareMlAmountGrid(mls:doneMl:onSelect:onCustom:)`.

### Pattern 3 — Page enum + deep link

**What:** New `pumpAmount` case + query `pump-amount`.

**Why:** TabView + deep links stay consistent.

**Example:** `BabyHomePage.fromQuery("pump-amount") == .pumpAmount`.

## Sequence

```text
Nap running → tap Nap
  → flags(.sleep): endOpenNap=false
  → advanceNap → .done
```

```text
Pump L running → tap Both
  → pumpLeft=idle; pumpBoth=running
```

```text
Bottle chip 90
  → related-stop → idle; bottleDoneMl flash; no lasting selected fill
```

## API contracts

N/A — Has API no.

## Database contracts

N/A — Has DB no.

## UI / UX / mobile

| Surface | Layout |
|---------|--------|
| Pump | Header + L \| R \| Both (timed chips; Both may span or 3-across — prefer **3 equal** in one row if space, else L\|R then Both full width). Recommendation: **row1 L\|R**, **row2 Both** full width for hit size — **OR** single row of three if readable. **Pick: one row of three equal chips** (match Feed breast density). |
| Pump amount / Bottle | Header tip; 3 ml; big Custom; footer tip |
| Diaper | `VStack(spacing: 0)` or 1 between icon and title |
| Last care | Icon + `lineLimit(1)` short sentence; feed `bottle.fill` / breast `mouth.fill` when typed; diaper `leaf.fill` |

**Last care short copy (samples):**

| Row | Sentence |
|-----|----------|
| Feed | `Bottle 120 ml · 25m` |
| Nap | `No nap yet` / `Napping · 12:04` |
| Diaper | `Wet · 1h` |
| Pump | `No pump yet` |

## OWASP

| Area | Notes |
|------|--------|
| A01 / A03 / Secrets | N/A local UI |

## Aggressive challenges

| Challenge | Response |
|-----------|----------|
| 7 pages too many? | User asked pump split; page dots OK on Watch. |
| Both + L/R both running? | Forbidden — exclusive slot. |
| leaf.fill for diaper? | Default; Gate B may pick another SF Symbol. |

## Has API / Has DB

- **Has API:** no
- **Has DB:** no
