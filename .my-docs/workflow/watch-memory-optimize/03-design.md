# Design: Lower MyBaby Watch memory (hygiene)

**Mode:** simple

**Has API:** no  
**Has DB:** no

## Decision 1: which design approach?

### Option 1 — Lifetime hygiene on current TabView (recommended)

**What it is:**
Keep the 7-page care map. Cut needless work and retains: cancel stacked done-flash Tasks; run chip `TimelineView` only when that page is selected and the scene is active; merge duplicate widget configs; re-check Memory Report after (Debug baseline already known).

**Example:**
`BabyHomeStatusModel` holds one cancellable clear Task; `TimedCareChip` gets `ticksEnabled: Bool` from page + `scenePhase`; `BabyCareWidgets` exposes one accessory widget kind.

**Pros:**
- Matches user Option 1; no UI/IA change
- Small, testable diffs; locks care behavior
- Targets real waste even if Debug ~22 MB is mostly SwiftUI runtime

**Cons:**
- May not drop Debug peak much (flat ~22 MB after launch is largely framework)
- Widget merge needs a quick face/Smart Stack sanity check

**Rejected alternative (≤3 lines):** Collapse pages into sheets to shrink TabView trees — rejected; user chose hygiene-only; IA stays.

## Tradeoffs

One-line: hygiene first vs IA rewrite — user picked hygiene; expect modest Debug peak change, clearer lifetime, less tick/Task waste.

## Recommendation

**Pick Option 1** — user approved; measure shows steady ~22 MB Debug (not a growing leak), so fix cancel/tick/widget hygiene and verify no growth under a running nap.

## Chosen design (user-approved)

Option 1 — Lifetime hygiene on current TabView (Gate B approved 2026-09-23).

## System design

N/A — no system-design change; same `ContentView` → model → page TabView → widgets appex; local sample state only (Has API/DB no).

## Design patterns used

### Pattern 1 — Cancellable deferred clear

- **What it is:** One stored `Task` (or work token) for done-flash clear; cancel before schedule.
- **How we use it here:** `scheduleClearDone` / `scheduleClearDoneForSide` share cancel-then-sleep-2s.
- **Why:** Stops Task stacks on rapid taps.
- **Best practices:** Cancel on re-entry; keep `@MainActor`.
- **Anti-pattern:** Fire-and-forget `Task` per tap with no cancel.
- **Reference:** `BabyHomeStatusModel.swift`

### Pattern 2 — Gated periodic TimelineView

- **What it is:** 1 Hz `TimelineView` only while chip is running **and** ticks are enabled (page visible + active scene).
- **How we use it here:** Pass `ticksEnabled` into `TimedCareChip`; idle/static label otherwise.
- **Why:** Avoids offscreen/background tick rebuilds during long naps.
- **Anti-pattern:** Wrap whole `TabView` in periodic TimelineView (already forbidden).
- **Reference:** `CareControls.swift`, `BabyHomeView` comment

### Pattern 3 — Single widget configuration

- **What it is:** One `StaticConfiguration` for all accessory families.
- **How we use it here:** Merge Complication + Smart Stack into one kind (or one kind + thin wrapper only if product requires two display names — prefer one).
- **Why:** Avoid duplicate timelines for overlapping families.
- **Reference:** `BabyCareWidgets.swift`

## Sequence diagram

```mermaid
sequenceDiagram
  participant User
  participant Chip as TimedCareChip
  participant Model as BabyHomeStatusModel
  participant Scene as scenePhase

  User->>Chip: tap start
  Chip->>Model: toggleTimed
  Model->>Model: phase = running
  Note over Chip: TimelineView 1Hz iff ticksEnabled
  Scene-->>Chip: background → ticksEnabled false
  User->>Chip: tap stop
  Chip->>Model: toggleTimed → done
  Model->>Model: cancel prior Task; sleep 2s → idle
```

## API contracts

N/A — no public HTTP/GraphQL/server-action change.

## Database contracts

N/A — no schema / migrations / persistence queries.

## Example queries

N/A

## UI / UX / mobile

- **Look:** Unchanged (Has UI no).
- **Behavior:** Timers still show m:ss while page selected and app active; done flash still ~2s.
- **Mobile/watch:** Honor `scenePhase`; never TabView-wide TimelineView.

## Security (OWASP)

| Topic | Notes |
|-------|--------|
| A01 Broken access | N/A — local UI |
| A04 Insecure design | No new trust boundary |
| A05 Security misconfig | No secrets; debug log file not shipped in app |
| Other | N/A for this hygiene pass |

## Aggressive challenges

- **Will Debug peak stay ~22 MB?** Likely yes — that jump is mostly SwiftUI/Debug. Success = no growth under nap + cleaner lifetime; optional Release check.
- **Will gating ticks confuse users?** Only if they leave a running timer page — subtitle freezes until they return (acceptable; elapsed still correct via `startedAt`).
- **Widget merge break faces?** Keep same deep-link URL helper; one kind covering all accessory families.

## Clarity check

Is this design clear? Which option do you approve? **Option 1** (user already chose). Any concerns before build?
