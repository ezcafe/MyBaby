# Design: Watch care rules + Feed/Bottle split

**Mode:** full

## Decision 1: which design approach?

### Option 1 — Local side-effect helper + page split (recommended)

**What it is:**  
Keep sample/local `BabyHomeStatusModel`. Add pure `CareSideEffects` mirroring web quick-care local+nap rules. Split pages; port chip builder `limit: 2`; remove nav title; smaller section detail.

**Example:**  
`model.toggleTimed(.breastLeft)` → `CareSideEffects.apply(.breastStartOrToggle, …)` clears `openNapStartedAt` / nap phase when open; pump toggles skip nap clear.

**Pros:**
- Matches user ask without waiting on GraphQL
- Unit-testable matrix
- Small blast radius

**Cons:**
- Must re-check when API wire lands (call real `babyQuickCare` later)

### Option 2 — Thin UI only; defer side effects to API

**What it is:**  
Split pages + chips + fonts now; leave timers independent until `babyQuickCare` is wired.

**Example:**  
Feed page exists but open nap stays running when breast starts.

**Pros:**
- Less model logic now

**Cons:**
- Fails the user’s Feed→stop sleep example
- Ships wrong night behavior

### Recommendation
**Pick Option 1** — behavior is the core ask; UI split alone is not enough.

## Settled locks (Gate A / A2)

| Lock | Value |
|------|-------|
| Pages | Feed → Bottle → Sleep → Diaper → Pump → Last care |
| Title | **Removed** |
| Bottle/Pump chips | 2 recommended + Custom; `buildBabyBottleChipMls` rule, `limit: 2` |
| Subtle | Section detail `.caption2` |
| Nap | Auto-end on breast / bottle / diaper (non-pump); pump does not |
| Breast | Stop on bottle / diaper / sleep when breast running; pump amount does not stop breast |

## System design

### Overview

- **UI:** `BabyHomeView` page TabView (6 pages); no navigation title.
- **State:** `@Observable BabyHomeStatusModel` owns timed phases, open nap, chip selection, footer.
- **Rules:** Pure `CareSideEffects` (+ chip builder in Shared) — no network.
- **Widgets:** Deep links map `feed`/`bottle` separately; overdue/next feed → `.feed`.

### Concept 1 — CareSideEffects

Input: action kind + current breast/pump/nap phases. Output: next phases (end nap?, clear breast?, leave pump?). Pump family never ends nap.

### Concept 2 — Chip mls

`BabyBottleChipMls.build(recentBottleMl:snaps:limit:)` — history first, then snaps; Watch `limit: 2`. Pump reuses bottle list.

## Design patterns used

### Pattern 1 — Pure resolver (existing)

Like `BabyCarePrimarySignal.resolve` / `CareFooterResolver`: side effects and chip lists are pure functions; model applies results. Teaches: test without SwiftUI.

### Pattern 2 — One job per page (IA)

Each TabView page owns one care job; no stacked Feed+Bottle. Teaches: Watch swipe = progressive disclosure.

### Pattern 3 — Port shared algorithm

Swift twin of `buildBabyBottleChipMls` keeps Watch aligned with web age-guide. Teaches: copy the rule, not the UI grid size (web 3 vs Watch 2).

## Sequence (breast start while nap open)

```text
User taps Left (idle)
  → CareSideEffects(.breast, napOpen: true)
  → end nap (phase done/clear openNapStartedAt)
  → start breastLeft running
  → haptic
```

```text
User taps Pump L while nap open
  → CareSideEffects(.pump, napOpen: true)
  → nap unchanged
  → start pumpLeft running
```

## API contracts

**N/A** this pass (Has API = no). Future: `babyQuickCare` per `docs/BABY_API.md`.

## Database contracts

**N/A** (Has DB = no).

## Example queries

**N/A.**

## UI notes

- Remove `.navigationTitle(...)` from `BabyHomeView`.
- `FeedPage` / `BottlePage` replace `FeedBottlePage`.
- `CareSectionHeader` detail font `.caption2`.
- Ml row: two chips + Custom (layout may be HStack / compact grid — not forced 2×2).

## OWASP / security

Local sample only; no new auth. When API lands, reuse clientRequestId idempotency (out of scope).

## Test plan (for TDD review)

1. Side-effect matrix (nap × breast/bottle/diaper/pump).
2. Chip builder history/snaps/limit 2.
3. Deep link `bottle` / `feed` / fallback.
4. Page enum case count / order.
5. Age title helper may remain tested but unused in UI.

## Risks

| Risk | Mitigation |
|------|------------|
| Rule drift vs web | Comment cites quick-care; table tests |
| Title removal surprises | Gate A2 approved |
| Chip snaps without birth | Use no-birth snaps truncated to 2 → `[60, 90]` |
