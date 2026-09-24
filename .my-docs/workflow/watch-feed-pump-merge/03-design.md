# Design: Watch Feed/Pump page merge + scroll

**Mode:** full

## Decision 1: which design approach?

### Option 1 — Collapse pages + in-page ScrollView (recommended)

**What it is:**
Remove Bottle and Pump amount from the TabView strip. Put bottle ml on Feed and pump ml on Pump. Wrap those two pages in `ScrollView`. Alias old deep-link queries to the merged pages.

**Example:**
`FeedPage` body: `ScrollView { VStack { header; breast chips; CareMlAmountGrid; footer } }`. `BabyHomePage.fromQuery("bottle") == .feed`.

**Pros:**
- Matches Gate A2 and user ask
- Reuses existing chips/grids
- Small blast radius; no API/DB

**Cons:**
- Must verify scroll vs horizontal swipe
- Tests/README churn for page order

### Option 2 — Amounts only in Custom sheet / overflow

**What it is:**
Keep one Feed and one Pump page but hide recommended ml behind a “Amount” button → sheet; no vertical scroll stack.

**Example:**
Feed shows breast only + “Bottle amount” button opening the current Bottle UI as a sheet.

**Pros:**
- Shorter above-the-fold height

**Cons:**
- Hides Gate A #2 (recommended chips)
- Extra tap vs scroll
- Diverges from web stack pattern approved at A2

## Tradeoffs

| Factor | Option 1 | Option 2 |
|--------|----------|----------|
| Cost / time | Low–med | Low |
| Complexity | Scroll + enum shrink | Sheet wiring |
| Usability | Chips same page | Extra tap |
| Failure cases | Gesture fight | Missed ml logging |

## Recommendation

**Pick Option 1** because Gate A2 approved stacked timers + amounts with scroll, matching prior Feed+Bottle home pattern and the user’s merge ask.

## Chosen design (user-approved)

**Option 1** — Collapse pages + in-page ScrollView (Gate B 2026-09-24).

## System design

### Overview

- **Runtime shape:** Watch UI only. `BabyHomeStatusModel` keeps local timers; Shared `BabyHomePage` is the page identity + deep-link map for app and widgets.
- **Boundaries:** No new network or persistence. Side-effect **actions** (`.bottle`, `.pumpAmount`) stay in `CareSideEffects`; they are not TabView pages.
- **Data ownership:** Snapshot + model own chip mls and phases; views compose only.
- **Consistency:** Deep-link aliases must resolve to merged pages so widgets/old URLs land correctly.
- **Failure domain:** UI/gesture only — wrong page enum breaks navigation tests, not server data.
- See Sequence + Contracts below (not restated here).

### Concept 1 — Page identity vs care action

- **Problem:** Bottle/pump amount were both swipe pages and side-effect actions.
- **Idea:** Pages shrink to five; actions stay for `selectBottle` / `selectPump`.
- **Tradeoff:** Query strings `bottle` / `pump-amount` no longer name distinct pages — they alias.

## Design patterns used

### Pattern 1 — Compose existing care controls

- **Problem:** Avoid new chip types for the merge.
- **Idea:** Stack `TimedCareChip` + `CareMlAmountGrid` in one scrollable page (same as early Feed+Bottle idea).
- **Apply:** `CarePages.swift` Feed/Pump only; delete Bottle/PumpAmount page structs.
- **Tradeoff:** Taller pages need scroll.

### Pattern 2 — Deep-link alias map

- **Problem:** Old URLs and docs still say `bottle` / `pump-amount`.
- **Idea:** `fromQuery` maps aliases to `.feed` / `.pump` (same pattern as `breast` → feed).
- **Apply:** `BabyHomePage.fromQuery`; tests assert aliases; README notes aliases.
- **Tradeoff:** `queryValue` for canonical pages stays `feed` / `pump` only.

### Pattern 3 — N/A further

N/A — no new repository/presenter layers.

## Sequence diagram

```mermaid
sequenceDiagram
  actor User
  participant Tab as BabyHomeView TabView
  participant Feed as FeedPage ScrollView
  participant Model as BabyHomeStatusModel
  participant FX as CareSideEffects

  User->>Tab: Swipe to Feed
  User->>Feed: Tap breast L
  Feed->>Model: toggleTimed(breastLeft)
  Model->>FX: flags(.breast)
  FX-->>Model: end nap if open
  User->>Feed: Scroll; tap 120 ml
  Feed->>Model: selectBottle(120)
  Model->>FX: flags(.bottle)
  Note over User,Tab: Pump page same pattern with pump timers + selectPump
```

## API contracts

**N/A — Has API = no.** No HTTP/GraphQL/server-action changes. Deep-link query aliases are client URL mapping only (`mybaby://home?page=…`).

## Database contracts

**N/A — Has DB = no.**

## Example queries

**N/A** — no persistence queries.

Deep-link examples (client):

| Query | Resolves to |
|-------|-------------|
| `page=feed` / `breast` / `bottle` | `.feed` |
| `page=pump` / `pump-amount` | `.pump` |
| `page=status` | `.lastCare` |

## UI / UX / mobile

- Aligns with Gate A / 01b: timers #1, amounts #2 on same page; Custom sheet secondary.
- Feed/Pump: `ScrollView` + existing header/controls/footer; no app title.
- Strip: Feed → Sleep → Diaper → Pump → Last care.
- Footer: feed tip on Feed; pump tip on Pump (remove “Swipe for amounts.”).
- Replace ui-refs with Watch sim screenshots after Build.

## OWASP (relevant rows)

| Risk | Apply? | Note |
|------|--------|------|
| A01 Broken access | n/a | Local sample UI |
| A03 Injection | low | Deep-link query switch only; no SQL |
| A07 Auth failures | n/a | Auth stub unchanged |
| Sensitive data | n/a | No new PII surfaces |

## Aggressive challenges

| Challenge | Response |
|-----------|----------|
| Scroll steals horizontal swipe | Test on sim; use plain ScrollView; avoid nested horizontal scroll |
| Users liked separate Bottle page | User + Gate A2 asked merge |
| Keep enum cases as ghosts | Rejected — confusing mount/tests |

## Has API / Has DB confirmation

- **Has API:** no
- **Has DB:** no
