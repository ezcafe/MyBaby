# Design: watch-complication-timer-status

**Mode:** full  
**Has API:** no · **Has DB:** no · **Has UI:** yes  
**UI lock:** `ui-refs/_proposed-complications.html` (Gate A2 approved)

## Decision 1: how to drive live face state?

### Option 1 — App Group timer mailbox + system `.timer` text (recommended)

**What it is:** Extend App Group DTO with running timer kind + start date and last-care event dates; model persists on every timer start/stop; widgets use `Text(start, style: .timer)` while running and teal/red last-care when idle.

**Example:** Start breast → DTO `{ runningKind: breastL, runningStartedAt }` → circular shows live `12:04` teal; stop → clear running → show `Last feed · 25m` teal or red from overdue band.

**Pros:**
- Matches Gate A2 and prior recommendation
- No per-second WidgetKit reloads
- Reuses existing store + one widget kind

**Cons:**
- DTO + mapper/`at` plumbing work
- Must persist breast/pump (new vs nap-only today)

### Option 2 — Timeline-only refresh (~1s / 1min) with static strings

**What it is:** Keep formatted strings; rebuild timeline every second while “running” (or keep ~1 min).

**Example:** Provider emits many entries with preformatted `12:04`, `12:05`, …

**Pros:** No reliance on `Text.DateStyle.timer` quirks

**Cons:**
- Battery / throttle risk; Apple discourages per-second entries
- Breast/pump still missing unless DTO extended anyway
- Fails “live” feel under throttling

### Recommendation

**Pick Option 1** — aligns with approved HTML, Apple dynamic dates, and existing App Group pattern.

## Settled product rules

| Rule | Choice |
|------|--------|
| Running priority | Open nap → breast L/R → pump L/R/Both |
| Idle primary | Last care among feed/nap/diaper/pump by latest `at` |
| In range color | Teal (`BabyTokens.accent`) |
| Out of range color | Red (`BabyTokens.danger`) when feed or diaper past recommendation interval for age stage |
| Next feed countdown | Secondary on rectangular only when idle; not primary |
| Families | circular, corner, rectangular, inline — one kind |
| Care type config | App Intent: Auto \| Feed \| Sleep \| Diaper \| Pump (default Auto) |
| Tap deep link | Fixed type → that page; Auto → page for resolved display |

## System design

### Overview

- Watch app owns timer phases + GraphQL status; writes App Group DTO (no token).
- Widget extension reads DTO → timeline entry → SwiftUI accessory views.
- No new HTTP/GraphQL contracts; parse existing `at` fields client-side for last-care ages.
- Point to Sequence for write/reload; OWASP: never put tokens in App Group (existing forbiddenKeys tests).

### Concept 1 — Running mailbox + idle band

App writes `runningStartedAt` / `runningKind` and last-event timestamps; widget chooses live `.timer` vs last-care + color band.

## Design patterns used

### Pattern 1 — App Group status mailbox

- **What:** Codable DTO in shared UserDefaults suite.
- **How:** Extend `BabyCareStatusDTO`; `persistStatusForWidgets` on all timed toggles + status load.
- **Why:** Widgets cannot see in-memory model.
- **Best practices:** version field; injectable `suiteName` tests; no secrets.
- **Anti-pattern:** Network from widget.
- **Reference:** `BabyCareStatusStore.swift`

### Pattern 2 — System dynamic date text

- **What:** `Text(date, style: .timer)` / relative for idle age.
- **How:** Pass stored `Date` into widget views; `.monospacedDigit()`.
- **Why:** Live digits without 1 Hz widget TimelineView.
- **Anti-pattern:** Custom `Timer` in appex.
- **Reference:** Apple WidgetKit dynamic dates; Gate A2 HTML

### Pattern 3 — Pure signal resolver

- **What:** Pure function snapshot → display model (kind, color, dates, deep link).
- **How:** Extend/replace `BabyCarePrimarySignal` (or sibling) for complication display.
- **Why:** Unit-testable; shared by all families.
- **Reference:** `BabyHomeStatusSnapshot.swift` tests

## Sequence diagram

```text
Parent → Watch App: start nap / breast / pump
Watch App → Model: phase = running(startedAt)
Model → App Group: write DTO (running + last ats)
Model → WidgetCenter: reloadTimelines(BabyCareComplication)
Widget → App Group: read DTO
Widget → Face: Text(startedAt, style: .timer) teal

Parent → Watch App: stop timer / status load
Model → App Group: clear running; refresh last ats / overdue band
Widget → Face: last care relative; teal or red
```

## API contracts

N/A — no public HTTP/GraphQL change. Continue using `at` on last* events already in `homeQuickStatus`.

## Database contracts

N/A

## Example queries / documents

```text
App Group key: BabyCareStatusDTO.v1 (bump version if needed → v2)
Fields add: runningKind?, runningStartedAt?, lastFeedAt?, lastNapAt?, lastDiaperAt?, lastPumpAt?
(keep existing openNapStartedAt for back-compat or migrate into running*)
```

## CareGuide out-of-range (client)

- Parse last feed/diaper `at` from GraphQL into snapshot.
- Out of range if age since that event exceeds stage interval (reuse CareGuide stage cuts; feed interval from tips/essay bands already mirrored — document concrete seconds table in Task 2).
- If interval unknown, fall back to existing `feedOverdueSeconds` / `diaperOverdueSeconds` when non-nil.

## UI parity (Build)

Match `_proposed-complications.html`: teal running + in-range; red out-of-range; rect 162×68 hierarchy (brand / primary / secondary); short circular value.

## Risks

| Risk | Mitigation |
|------|------------|
| `.timer` truncates on circular | Short value only; ViewThatFits if needed |
| Breast start forgotten persist | Checklist + unit test on persist hooks |
| Overdue nil from mapper | Compute from `at` + CareGuide |
| Always On red washout | Use danger token; keep icon+word |

## OWASP (relevant)

| Topic | How this design handles it |
|-------|----------------------------|
| A01 Broken access | Widgets never call APIs; no new auth |
| A02 Cryptographic failures | Token stays Keychain; App Group status-only + forbiddenKeys tests |
| A03 Injection | No new SQL/query strings; Codable DTO only |
| A04 Insecure design | Read-only widgets; app owns writes |
| A05 Misconfiguration | Keep existing entitlements App Group id |
| A07 Auth failures | Unchanged pairing / logout clears Keychain |
| A09 Logging | Do not log tokens when debugging persist |

## A11y / mobile

- Color not sole cue: kind icon/label with red/teal
- Dynamic Type / short labels on circular; VoiceOver uses label + value
- Hit targets remain in-app (≥44); complication is glance + deep link

## Open questions before Gate B

None blocking — intervals table filled in Task 2 from `CareGuideStage` / tip bands.
