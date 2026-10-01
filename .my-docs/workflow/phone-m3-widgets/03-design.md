# Design: phone-m3-widgets

**Mode:** full  
**Has API:** no · **Has DB:** no · **Has UI:** yes  
**Updated:** 2026-09-30  
**Grill:** frontier-empty — N1 `BabyCarePhoneHome` · N2 small+medium · N3 Phone intent · N4 strip stubs

## Decision 1: How to deliver Phone Home Screen widgets?

### Option 1 — Shared mailbox + display; Phone-only WidgetKit UI (recommended)

- **What it is:** Keep `BabyCareStatusStore` + `BabyCareComplicationDisplay` + timeline helper in Shared. Implement Phone Widgets provider/views for systemSmall/Medium. Dual-reload Watch + Phone kinds from `persistStatusForWidgets`. Strip Control/Live Activity from bundle.
- **Example:** Phone app starts breast → DTO saved → reload `BabyCarePhoneHome` → small widget shows teal `.timer` + “Breast L”.
- **Pros:** Matches Gate A; reuses proven Watch rules; no network; fastest honest glance.
- **Cons:** Duplicate AppIntent enum/cases vs Watch file; two kind strings to maintain.

### Option 2 — Live Activity / Dynamic Island as primary glance

- **What it is:** Promote running timers to Live Activities; skip or minimize Home Screen widgets.
- **Example:** Start nap → Dynamic Island timer; dismiss when stop.
- **Pros:** Strong while timer runs.
- **Cons:** Weak for idle last-care color; not always on Home Screen; idea non-goal; more platform complexity.

### Recommendation

**Pick Option 1** — user-first permanent Home Screen glance; grill N1–N4.

## Chosen design (locks)

### Widget product

1. Kind: **`BabyCarePhoneHome`**
2. Families: **systemSmall**, **systemMedium**
3. Config: Care type Auto | Feed | Sleep | Diaper | Pump (default Auto)
4. Running: `Text(startedAt, style: .timer)` + kind label/icon from display
5. Idle: last-care relative/time + teal (`BabyTokens.accent`) / red (danger/overdue)
6. Medium may show one secondary line (next feed) when idle — same spirit as Watch rectangular
7. Tap: `widgetURL` → `BabyHomeDeepLink.url(page:)`
8. Empty suite: existing `snapshotForWidgets` / sample fallback

### App wiring

1. Shared constants: Watch kind `BabyCareComplication` + Phone kind `BabyCarePhoneHome`
2. `persistStatusForWidgets` reloads **both**
3. Phone Widgets target: membership for Shared status/display/timeline/deep link/tokens as needed
4. Bundle: only Baby Care Home Screen widget (no Control, no Live Activity)

### UI specs (Has UI)

- **#1** Primary value always visible (timer or last-care time)
- **#2** Kind cue / teal-red always visible
- Care type only in widget Edit sheet
- No logging chips on widget

## System design

### Overview

- **Runtime:** Phone App / Watch App write App Group DTO → WidgetKit extension reads DTO → timeline entry → SwiftUI.
- **Boundaries:** Widget process has no Keychain token use and no GraphQL; App Group is status-only.
- **Ownership:** Display rules Shared; Phone family views in Phone Widgets target; Watch accessory views stay Watch Widgets.
- Point to Sequence; OWASP: forbiddenKeys unchanged.

### Concept 1 — Dual-kind reload mailbox

One DTO writer; two widget kinds (Watch + Phone) both reload after persist.

## Design patterns used

### 1. App Group status mailbox

- **What:** Codable DTO in shared UserDefaults suite.
- **How:** Existing `BabyCareStatusStore`; Phone provider loads same suite.
- **Why:** Widget cannot see in-memory model.
- **Anti-pattern:** Network from widget; secrets in suite.
- **Reference:** `BabyCareStatusStore.swift`

### 2. Pure display resolve + platform views

- **What:** `BabyCareComplicationDisplay.resolve` picks timer vs idle + color + deep link.
- **How:** Phone views bind to display; do not reimplement priority.
- **Why:** Watch/Phone meaning stay identical.
- **Anti-pattern:** Forked Auto priority in Phone.
- **Reference:** `BabyCareComplicationDisplay.swift`

## Sequence

```text
Caregiver starts breast (Phone app)
  → BabyHomeStatusModel updates snapshot
  → persistStatusForWidgets()
  → BabyCareStatusStore.save(DTO)
  → WidgetCenter.reloadTimelines(BabyCareComplication)
  → WidgetCenter.reloadTimelines(BabyCarePhoneHome)
  → Phone widget Provider.timeline loads DTO
  → resolve(Auto) → running breast display
  → EntryView shows Text(start, .timer) teal
Caregiver taps widget
  → mybaby://home?page=feed
  → Phone app opens Feed tab
```

## API contract

**N/A** — no new HTTP/GraphQL. Widget reads local App Group only.

## Database contract

**N/A** — no CloudKit/schema change. App Group is not the Offline store.

## Example queries / loads

```swift
// Widget provider (conceptual)
let snap = BabyCareStatusStore.snapshotForWidgets()
let display = BabyCareComplicationDisplay.resolve(snap, careType: config.careType, now: .now)
let next = BabyCareWidgetTimeline.nextUpdate(for: snap)
```

## Security design (OWASP client)

- No token in DTO / App Group (`forbiddenKeys` tests remain)
- Widget does not read Keychain for API calls
- Deep link opens app pages only (existing scheme)

## Success criteria (design)

- [ ] Stub emoji gone; Control/Live Activity not in bundle
- [ ] Small + medium show timer / last-care + color
- [ ] Care type config works
- [ ] Dual reload kinds
- [ ] Tests + Phone Widgets build
