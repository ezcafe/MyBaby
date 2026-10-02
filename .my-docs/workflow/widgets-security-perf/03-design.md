# Design: widgets-security-perf

**Mode:** full  
**Chosen (pending Gate B):** Option 1  
**Has UI:** yes — empty honesty + privacy redaction only (no IA change)  
**Has API:** no  
**Has DB:** no  
**Grill:** frontier-empty · human `1/1/1/1`

## Decision 6: How wide is the Widgets security/perf pack?

### Option 1 — Trust + privacy + verify refresh (recommended)

- **What it is:** Honest empty mailbox snapshot; secondary-line `privacySensitive`; keep mailbox forbidden-key tests; verify timeline/coalescer with tests/docs only (no numeric tune). Shared “No care yet”.
- **Example:** Empty App Group → empty face; locked Lock Screen redacts primary + secondary ages; coalesce stays 750ms.
- **Pros:** Hits Gate A vital few; small blast radius; matches Grill.
- **Cons:** No further battery interval experiments this pack.

### Option 2 — Option 1 + aggressive refresh tune

- **What it is:** Same trust/privacy plus change coalescer delay and/or `nextUpdate` idle/timer intervals.
- **Example:** Idle refresh 30m; coalesce 1.5s.
- **Pros:** Possible battery gain.
- **Cons:** Staler faces; needs Instruments; Grill picked verify-only.

### Recommendation

**Pick Option 1** — user-first: honest + private faces without surprise staleness.

## Chosen design

**Option 1** (pending Gate B).

## UI specs (Has UI)

| Surface | Spec |
|---------|------|
| Phone small/medium/accessory* | Empty mode → “No care yet”; primary care times stay privacySensitive; **secondary care-time Text** also privacySensitive |
| Watch accessory* | Same empty string; secondary care-time Text privacySensitive |
| Gallery / placeholder | Still use `sample*` / `isPreview` samples |
| Edit Care type | Unchanged (Auto default) |
| Layout / overdue cues / a11y hierarchy | Unchanged (prior HIG packs) |

## System design

### Overview

- **Boundaries:** Apps write App Group DTO → coalesced `WidgetCenter.reloadTimelines` for both kinds → extensions read `snapshotForWidgets` → `BabyCareComplicationDisplay.resolve` → faces.
- **Trust:** Empty load → `emptyForWidgets` (not sample). DTO never tokens. Extensions never network.
- **Privacy:** Care ages on primary + secondary Text use `.privacySensitive()`.
- **Freshness:** Existing `BabyCareWidgetTimeline.nextUpdate` + 750ms coalescer unchanged; tests lock behavior.
- Point to Sequence / OWASP below.

### Concept 1 — Honest empty mailbox

Nil App Group data maps to an empty care snapshot that resolves to `mode.empty`.

### Concept 2 — Preview vs live

`context.isPreview` / `placeholder` keep samples; live timeline never invents care.

### Concept 3 — Coalesced dual-kind notify

One mailbox → reload Phone + Watch kinds after debounce (already shipped).

## Design patterns used

### Pattern 1 — Shared mailbox + thin views

- **What:** Store owns empty/live snapshot; views stay presentation-only.
- **Why:** Phone/Watch stay honest together.
- **Best practice:** Unit-test empty path + forbidden keys; do not fork empty UI per platform.
- **Repo:** `BabyCareStatusStore`, display empty helpers.

### Pattern 2 — privacySensitive on personal times

- **What:** Mark Text that shows care timers/relative ages.
- **Why:** Lock Screen / Always On / shared glance.
- **Best practice:** Apply to secondary ages too when they encode care time.
- **Repo:** Existing primary `.privacySensitive()` on Phone/Watch widgets.

### Pattern 3 — Coalescer for WidgetKit side effects

- **What:** Debounce reload; save DTO immediately.
- **Why:** Avoid thrash on rapid care taps.
- **Best practice:** Verify with recording reloader tests; do not tune without evidence.
- **Repo:** `WidgetTimelineReloadCoalescer`.

## Sequence

```text
App persistStatusForWidgets
  → encode BabyCareStatusDTO (no secrets) → App Group
  → coalescer.schedule (750ms) → reload both kinds

Widget timeline / snapshot
  → load DTO?
       no  → emptyForWidgets → resolve → “No care yet”
       yes → apply onto empty base → resolve → face
  → preview/placeholder → sample*
  → EntryView: privacySensitive on primary + secondary care times
  → tap → BabyHomeDeepLink (known page only)
```

## API contracts

N/A — Has API no.

## Database contracts

N/A — Has DB no. (App Group UserDefaults mailbox only.)

## Example queries

N/A.

## OWASP (widget / extension)

| Area | Control |
|------|---------|
| A01 Broken access | Extension: App Group status only; no Keychain token read |
| A02 Cryptographic failures | Tokens stay Keychain (apps); never DTO |
| A04 Insecure design | Honest empty; no sample-as-live |
| A05 Security misconfig | Widgets entitlements = App Group only |
| A09 Logging | Do not log DTO / secrets |
| Privacy | privacySensitive on care-time Text |

## Non-goals

- HIG layout redesign; Live Activities; interactive buttons
- App ATS / token hardening (prior app security-perf)
- Changing coalesce delay or nextUpdate intervals
- New widget kinds / App Group IDs

## Rejected alternative (short)

Option 2 refresh tune — Grill Q3 Option 1; defer until Instruments shows thrash.
