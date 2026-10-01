# Design: watch-widget-hig

**Mode:** full  
**Grill:** drop rectangular title; circular overdue text/symbol (keep kind icon); keep hex accents; wire shared helpers + privacySensitive

## Decision 1: How wide is the Watch HIG pack?

### Option 1 — Wire shared HIG helpers (recommended)

- **What it is:** Update Watch accessory views only: accessibilitySummary, emptyPrimaryText, showsOverdueCue on circular (+ corner/inline as space allows), drop rectangular brand title, privacySensitive on times. No new families; no display API changes unless a tiny layout helper is needed.
- **Example:** Circular idle overdue shows kind icon + age + “Overdue”; VO: “Feed overdue, 3h ago”; empty shows “No care yet”.
- **Pros:** Hits Gate A #1/#2; reuses Phone-tested helpers; smallest blast radius.
- **Cons:** Corner/inline overdue cue may stay minimal if space is tight.

### Option 2 — Helpers + Always On / accent chrome pass

- **What it is:** Option 1 plus system-style accent / Always On contrast pass on all families.
- **Example:** Replace hard hex with semantic accessory colors while keeping teal/red meaning.
- **Pros:** Better Always On polish.
- **Cons:** Larger visual QA; risk of meaning drift; Grill deferred this.

### Recommendation

**Pick Option 1** — user-first glance a11y/empty/overdue first; accent polish later if needed.

## Chosen design

**Option 2** (Gate B user approved) — Option 1 plus Always On / accent chrome via `BabyTokens` (match Phone widget accent/danger), not hard-coded hex.

## UI specs (Has UI)

| Surface | Spec |
|---------|------|
| accessoryCircular | #1 primary (timer/age); #2 kind icon; when `showsOverdueCue` add short overdue text/symbol (keep kind icon); empty → `emptyPrimaryText`; combined accessibilityLabel |
| accessoryCorner | Primary age/timer + kind label; overdue cue if space; empty clear copy; accessibilityLabel |
| accessoryInline | Kind + primary; empty clear; privacySensitive on times; accessibilityLabel |
| accessoryRectangular | Kind + primary dominate; **no** face “Baby Care” title; secondary overdue/sentence; privacySensitive on times |
| All families accents | Use `BabyTokens.accent` / `BabyTokens.danger` (colorScheme) like Phone widgets — no hard hex `0x2DD4BF` / `0xF87171` |
| Secondary / muted | Prefer `BabyTokens.muted` (or `.secondary`) for rectangular secondary line |
| Edit / gallery | Care type Auto default; configurationDisplayName “Baby Care”; placeholder/snapshot samples unchanged |
| New families | **out of this pack** |

## System design

### Overview

- **Boundaries:** Watch Widgets extension (UI) ↔ App Group mailbox (read) ↔ `BabyCareComplicationDisplay` (resolve + a11y/empty/overdue). Watch App still writes mailbox + coalesced reload.
- **Trust:** Extension never networks; never reads tokens. Care times use `privacySensitive`.
- **Freshness:** Existing timeline policy + kind reload remain.
- Point to Sequence / OWASP below.

### Concept 1 — Shared glance model

One `resolve` output drives all accessory families + VoiceOver (same as Phone).

### Concept 2 — Empty vs sample

Nil mailbox → sample (store). Resolved `mode.empty` → honest empty copy on face.

## Design patterns used

### Pattern 1 — Shared presentation model

- **What:** `BabyCareComplicationDisplay` owns meaning; Watch views stay thin.
- **Why:** Avoid Phone/Watch rule drift.
- **Best practice:** Wire existing helpers; unit tests already cover strings.
- **Repo:** Display + Watch AppTests a11y/empty/overdue tests.

### Pattern 2 — Accessory widget chrome

- **What:** Compact accessory layouts; demote redundant brand on rectangular; system fonts + monospacedDigit; **BabyTokens** accent/danger for Always On–friendly contrast (Option 2).
- **Why:** HIG Widgets glance on tiny faces; Phone already uses tokens.
- **Best practice:** Primary value + kind dominate; secondary one line max on rectangular; no hard hex accents.
- **Repo:** Current `BabyCareWidgets.swift`; Phone HIG layouts as reference.

### Pattern 3 — App Intent configuration

- **What:** Keep `BabyCareComplicationIntent` + recommendations; families unchanged.
- **Why:** Face / Smart Stack Edit already correct.
- **Best practice:** No new parameters this pack.
- **Repo:** Intent in `BabyCareWidgets.swift`.

## Sequence

```text
Parent logs care in Watch App
  → persist App Group DTO + coalesced WidgetCenter reload
  → TimelineProvider reads snapshotForWidgets
  → resolve(display) → BabyCareWidgetEntryView (accessory*)
  → VoiceOver reads accessibilitySummary
  → Always On / privacy may redact privacySensitive times
  → Tap → widgetURL deep link → care page
```

## API contracts

N/A — Has API no.

## Database contracts

N/A — Has DB no.

## OWASP (widget surface)

| Item | Note |
|------|------|
| A01 | No auth in extension; App Group status only |
| A02 | No tokens in mailbox / widget |
| A03 | No injection surface (local DTO) |
| A04 | Deep link opens app pages only |
| A05 | Entitlements App Group unchanged |
| A07 | No logging secrets from widget |
| A09 | N/A logging |
| Privacy | `privacySensitive` on care times |

## Rejected alternative (≤3 lines)

Option 1 alone (no token accents) — superseded by Gate B Option 2. Interactive buttons / new families — non-goals.
