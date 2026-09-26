# Analysis: watch-hig-ui

**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit after retry

## Overall deep dive

1. **What is this?** Bring MyBaby Watch UI in line with Apple watchOS 10+ HIG: vertical Crown pages, meaning-bearing backgrounds, denser pages collapsed to sheets, materials, Last care infographic, live App Group widgets, short Connect, toolbar loading / Retry ergonomics.
2. **Why do we need this?** Horizontal swipe + flat chrome + sample widgets fight glanceability and one-thumb night use; skipping keeps an iPhone-ported Watch app.
3. **How to do this?** Implement approved `ui-refs` on existing TabView + shared snapshot; add App Group store; no new GraphQL/DB. Other ways: keep horizontal pages (reject — fails HIG); network-from-widget (reject — Has API + battery). Best practices: Apple `.verticalPage` + `containerBackground`; WidgetKit App Group; keep ±1 mount + chip-scoped TimelineView.

## Solution pieces (≤5)

### 1. Vertical pages + containerBackground

- **What:** `.tabViewStyle(.verticalPage)` + per-page/urgency gradient backgrounds.
- **Why:** Crown navigation + sense of place.
- **How:** Change `BabyHomeView` style; helper maps page/state → Color/gradient; apply `.containerBackground(..., for: .tabView)`. Other: `.page` + dots only — reject. Best practice: Apple watchOS 10 docs.

### 2. Density sheets (Feed Bottle / Pump amounts)

- **What:** Feed shows L/R + Bottle; Bottle sheet has 3 ml + Custom. Pump keeps L/R/Both; amounts in sheet.
- **Why:** One-screen primary path; matches Gate A2 HTML.
- **How:** Reuse `CareMlAmountGrid` + `CustomMlPicker` in sheets; remove inline ml grids from Feed/Pump pages. Other: keep inline ml — reject (scroll). Best practice: progressive disclosure.

### 3. Materials + loading/Retry chrome

- **What:** Idle chips use material/surface without heavy hairline; toolbar ProgressView; Retry in bottom toolbar when fail.
- **Why:** Native hierarchy + Always On / reach.
- **How:** Update `TimedCareChip` / grids; move Updating off header text; Settings use system `role: .destructive`. Other: keep hairline everywhere — weaker HIG.

### 4. Last care infographic

- **What:** Large primary signal + short status rows.
- **Why:** Glanceable status page.
- **How:** Reuse `BabyCarePrimarySignal.resolve` for hero; keep existing rows under it. Other: dial rings — nicer later, more work.

### 5. App Group live widgets + short Connect

- **What:** Persist snapshot to App Group; widgets read it; Connect = presets + code + Save; Need help? disclosure.
- **Why:** Live face signal; less setup friction.
- **How:** `BabyCareShared` store (Codable wire format or PropertyList); entitlements `group.vn.in4.MyBaby` on Watch app + widgets; write on status load / timer-relevant updates; `WidgetCenter.reloadTimelines`. Connect: DisclosureGroup for help/Advanced. Other: sample forever — reject (in scope).

## Decision A — Snapshot wire format

### Option 1 — Codable DTO in Shared (recommended)
- **What:** Lightweight `BabyHomeStatusStoreDTO` Codable write/read via App Group `UserDefaults` or file.
- **Example:** Encode openNap, nextFeed, last lines, ageDays after `loadLiveStatus`.
- **Pros:** Testable; clear versioning field.
- **Cons:** Must keep DTO in sync with snapshot fields used by widgets.

### Option 2 — Full snapshot Codable
- **What:** Make `BabyHomeStatusSnapshot` Codable as-is.
- **Pros:** One type.
- **Cons:** Tips/chips bloat; harder evolution.

### Recommendation
**Pick Option 1** — widgets only need signal + a few lines.

## Reusable patterns

- `BabyHomeView` TabView + ±1 mount
- `BabyCarePrimarySignal` / `BabyCareWidgetTimeline`
- `CareMlAmountGrid` / `CustomMlPicker` sheets
- Teal `BabyTokens` / `BabyPalette`
- Existing unit tests in `MyBaby_Watch_AppTests.swift`

## System shape candidates

- Watch app writes App Group → WidgetKit reads (no new server)
- UI-only navigation/chrome changes stay in Watch App Views + Theme

## Spike notes

N/A — no entitlements file yet; Design must add `.entitlements` for both targets.

## Has API / Has DB

- **Has API:** no — no public HTTP/GraphQL contract change
- **Has DB:** no — App Group client store only

## Clear enough to design?

yes — Gate A2 HTML locked; open items: exact App Group ID string (`group.vn.in4.MyBaby`), Pump amount sheet trigger label (“Amount” / “Pump ml”).

## Key file paths

- `MyBaby Watch App/Views/BabyHomeView.swift`
- `MyBaby Watch App/Views/Pages/CarePages.swift`
- `MyBaby Watch App/Views/Components/CareControls.swift`
- `MyBaby Watch App/Views/AuthConnectView.swift`
- `BabyCareShared/*`
- `MyBaby Watch Widgets/BabyCareWidgets.swift`
- `MyBaby.xcodeproj/project.pbxproj`
