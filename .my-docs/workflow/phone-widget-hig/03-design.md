# Design: phone-widget-hig

**Mode:** full  
**Grill:** shared a11y + sample-on-nil; **Gate B Option 2** adds Lock Screen accessory (overrides Grill Q1 Home-only)

## Decision 1: How wide is the HIG pack?

### Option 1 — Home Screen HIG pack

- **What it is:** Fix a11y summary, overdue non-color cue on small, empty primary copy, layout hierarchy/margins on systemSmall + systemMedium only.
- **Example:** Small shows icon + “Overdue” when red; VO: “Feed overdue, 3h ago”; empty mode shows “No care yet”.
- **Pros:** Hits Gate A #1/#2; smallest risk.
- **Cons:** No Lock Screen this pass.

### Option 2 — Home + Lock Screen accessory (recommended after Gate B)

- **What it is:** Option 1 plus Phone Lock Screen families (`accessoryRectangular` + circular/inline) reusing Watch meaning; `privacySensitive` on care times.
- **Example:** Lock Screen row: kind + timer/relative + overdue line; redacted when privacy requires.
- **Pros:** More glance surfaces for caregivers.
- **Cons:** Privacy/redacted QA; slightly larger layout surface.

### Recommendation

**Pick Option 2** — Gate B user choice.

## Chosen design

**Option 2** (Gate B approved).

## UI specs (Has UI)

| Surface | Spec |
|---------|------|
| systemSmall | #1 primary value; #2 kind Label/icon; when overdue add text/symbol (not color alone); empty → “No care yet”; combined accessibility label |
| systemMedium | Same #1/#2; one secondary line; demote/remove redundant “Baby Care” title; system margins |
| accessoryRectangular | Kind + primary + secondary (overdue / last feed); privacySensitive on times |
| accessoryCircular / inline | Compact kind + primary (Watch meaning); privacySensitive on times |
| Edit sheet | Care type Auto default unchanged |
| Gallery | placeholder/snapshot samples unchanged |
| systemLarge | **out of this pack** |

## System design

### Overview

- **Boundaries:** Phone WidgetsExtension (UI) ↔ App Group mailbox (read) ↔ `BabyCareComplicationDisplay` (resolve + a11y strings). App process still writes mailbox + coalesced reload.
- **Trust:** Extension never networks; never reads tokens. Lock Screen uses `privacySensitive` on timer/relative values.
- **Freshness:** Existing timeline policy + dual-kind reload remain.
- Point to Sequence / OWASP below.

### Concept 1 — Shared glance model

One `resolve` output drives Home + Lock Screen + VoiceOver.

### Concept 2 — Empty vs sample

Nil mailbox → sample (store). Resolved `mode.empty` → honest empty copy on face.

## Design patterns used

### Pattern 1 — Shared presentation model

- **What:** `BabyCareComplicationDisplay` owns meaning; views stay thin.
- **Why:** Avoid Phone/Watch rule drift.
- **Best practice:** Add `accessibilitySummary` + overdue/empty helpers; unit-test strings.
- **Repo:** Existing display + Watch AppTests.

### Pattern 2 — System widget chrome

- **What:** Prefer system fonts, margins, `containerBackground`; lean padding; accessory chrome for Lock Screen.
- **Why:** HIG Widgets glance + Dynamic Type.
- **Best practice:** Do not fight widget content margins with 4pt padding.
- **Repo:** Current `containerBackground` + `BabyTokens`; Watch accessory layouts.

### Pattern 3 — App Intent configuration

- **What:** Keep `BabyCarePhoneHomeIntent` + recommendations; expand `supportedFamilies`.
- **Why:** Gallery / Edit Care type already correct.
- **Best practice:** No new parameters this pack.
- **Repo:** `AppIntent.swift`.

## Sequence

```text
Parent logs care in Phone App
  → persist App Group DTO + coalesced WidgetCenter reload
  → TimelineProvider reads snapshotForWidgets
  → resolve(display) → EntryView (small/medium/accessory*)
  → VoiceOver reads accessibilitySummary
  → Lock Screen may redact privacySensitive times
  → Tap → widgetURL deep link → care tab
```

## API contracts

N/A — Has API no.

## Database contracts

N/A — Has DB no.

## Example queries

N/A

## OWASP / security notes

| Topic | Note |
|-------|------|
| A01 Broken access | Extension reads App Group only; no token keys |
| A04 Insecure design | Lock Screen: mark care times `privacySensitive` |
| A09 Logging | Do not log DTO from widget |
| Privacy | Redacted lock presentation for timer/relative |

## Non-goals

- Interactive care buttons, Live Activities, network, systemLarge, care rule changes, Phone in-app HIG, changing sample-on-nil.

## Risks

| Risk | Mitigation |
|------|------------|
| VO + `.timer` quirks | Combined accessibility element |
| Empty vs sample | Only change `mode.empty` branch |
| Lock Screen privacy | `privacySensitive` on times |
| Accessory density | Reuse Watch rectangular/circular/inline patterns |

## Acceptance

- [ ] Shared a11y helper unit-tested
- [ ] Small overdue non-color cue
- [ ] Empty mode primary ≠ “·”
- [ ] Medium hierarchy without redundant brand title
- [ ] Lock Screen accessory families build + show kind/primary
- [ ] Phone WidgetsExtension BUILD SUCCEEDED
- [ ] Existing display tests still green
