# Design: watch-hig-ui

**Mode:** full  
**Build lock:** Match approved `ui-refs/_proposed-feed-vertical.html`, `_proposed-sleep-bg.html`, `_proposed-last-care.html`, `_proposed-connect-short.html`, `_proposed-complication-rect.html` (size, positions, texts, chrome).  
**Note:** main-thread fallback — usage limit

## Decision 1: which design approach?

### Option 1 — Incremental HIG pack on current shell (recommended)

**What it is:** Keep 5-page TabView + gear sheet + Observable model; swap to `.verticalPage`, add backgrounds/materials/sheets/infographic/App Group store/short Connect.

**Example:** Feed shows Left/Right + Bottle → sheet with 90/120/150 + Custom; widgets read App Group after `loadLiveStatus`.

**Pros:** Matches Gate A2; reuses chips/signal helpers; no API/DB; smaller blast radius.

**Cons:** Entitlements + Codable DTO + Xcode signing setup; vertical nav habit change.

### Option 2 — NavigationSplitView source list + detail

**What it is:** Care types in carousel list; detail pages for each job.

**Example:** List Feed/Sleep/… → detail with chips.

**Pros:** Very Apple for many destinations.

**Cons:** Extra tap vs Crown pages; diverges from approved HTML (vertical TabView + dots).

### Recommendation

**Pick Option 1** — locks to approved HTML and Crown-first pages.

## Chosen design (Option 1)

### Navigation + place

- `BabyHomeView`: `.tabViewStyle(.verticalPage)`.
- `CarePageBackground.color(page:urgency:)` → `.containerBackground(_:for: .tabView)` on each page root.
  - Feed: teal wash; overdue feed: stronger/warm tint
  - Sleep / open nap: indigo → dark
  - Diaper: neutral; overdue: caution tint
  - Pump: soft teal
  - Last care: cool sky wash
  - Fail state: optional danger wash behind page (subtle)

### Density

- **Feed:** Breast L/R + `Bottle` button → sheet with `CareMlAmountGrid` + Custom (HTML).
- **Pump:** L/R/Both on page; `Amount` button → same ml sheet pattern for pump select.
- Drop page-level ScrollView when content fits; keep ScrollView only if needed on Last care.

### Chrome / materials

- Idle chips: material / translucent surface; light hairline optional; running/done solid accent; fail danger (keep identity).
- Toolbar trailing: gear; leading or trailing `ProgressView` when `isStatusLoading` (remove header “Updating…” text).
- On fail: bottom toolbar `Retry` (keep footer tip/recovery text as needed).
- Settings sheet: system destructive Log out + prominent Reconnect.

### Last care

- Hero: `BabyCarePrimarySignal` short label + large value (timer / minutes).
- Then existing status rows (icons + sentences); no competing large title beyond optional muted lead.

### Widgets + App Group

- Entitlements both targets: `group.vn.in4.MyBaby`.
- Shared: `BabyCareStatusStore` write/read DTO (version, openNapStartedAt, nextFeed/overdue/diaper overdue, lastFeed/Nap/Diaper sentences+icons, ageDays, writtenAt).
- Model writes after successful `loadLiveStatus` and when local timer state that affects primary signal changes (open nap start/stop at minimum).
- Provider `getTimeline` / snapshot: read store → map to snapshot-like fields for signal; fallback sample if empty.
- Rectangular: brand + primary + one secondary (HTML). Circular/corner/inline keep short primary.
- `WidgetCenter.shared.reloadTimelines(ofKind:)` after write.

### Connect

- Primary: Local/Production, Pairing code, Save & connect.
- `DisclosureGroup("Need help?")` holds steps + Advanced paste token.
- Match `_proposed-connect-short.html`.

### Always On / ergonomics

- Running timer subtitle stays high contrast; avoid dimming elapsed text.
- Primary chips remain in lower/mid content (not under toolbar only).

## System design

### Overview

- Watch-only UI + shared client store; **Has API no**, **Has DB no**.
- Runtime: ContentView → NavigationStack → BabyHomeView (vertical TabView) ↔ App Group ← Widget extension.
- Auth/pairing unchanged (redeem + GraphQL).
- Point to Sequence for write/reload; OWASP for Keychain/token (unchanged).

### Concept 1 — App Group as widget mailbox

App owns freshness; widgets are read-only consumers of last written DTO + timeline policy.

## Design patterns used

### 1. Observable model + thin views
**What:** Model owns status/loading/fail; views bind.  
**How:** Extend write-to-store hooks on existing load/timer paths.  
**Why:** Keeps TabView light.  
**Best practices:** Match current `BabyHomeStatusModel`.

### 2. Progressive disclosure (sheets / DisclosureGroup)
**What:** Secondary density off primary page.  
**How:** Bottle/Amount sheets; Need help?.  
**Why:** One-screen primary.  
**Best practices:** Apple Watch short sessions.

### 3. Shared DTO store
**What:** Versioned Codable mailbox.  
**How:** `BabyCareStatusStore` in `BabyCareShared`.  
**Why:** Widgets + tests without full snapshot Codable.  
**Best practices:** WidgetKit App Group samples.

## Sequence diagram

```text
Parent → Watch App: open / Crown page / tap chip
Watch App → Model: toggle / select / loadLiveStatus
Model → GraphQL (live): babyQuickCare / status (unchanged)
Model → App Group store: write DTO
Model → WidgetCenter: reloadTimelines
Widget → App Group: read DTO → timeline entry → face
```

## API contracts

N/A — no public HTTP/GraphQL changes.

## Database contracts

N/A — no Postgres/schema. App Group `UserDefaults`/file is client cache only.

## Example queries / documents

```text
Key: BabyCareStatusDTO.v1 (UserDefaults suite group.vn.in4.MyBaby)
Fields: version, writtenAt, openNapStartedAt?, nextFeedInSeconds?, feedOverdueSeconds?, diaperOverdueSeconds?, lastFeed{icon,sentence}, lastNap, lastDiaper, ageDays
```

## UI / UX / mobile

- Build **must match** approved HTML ui-refs (vertical dots cue, Feed Bottle sheet, Sleep indigo, Last care hero, Connect Need help?, rect complication density).
- Hits ≥44pt; teal tokens; no emoji in product UI.
- Do not re-argue Gate A 80/20.

## OWASP (relevant)

| Area | Mitigation |
|------|------------|
| A01 Broken access | Token stays Keychain; App Group holds status only (no token) |
| A02 Cryptographic | No new secrets in App Group |
| A04 Insecure design | Logout confirm unchanged |
| A05 Misconfig | Entitlements only needed App Group |
| A09 Logging | Do not log token/pairing code |

## Aggressive challenges

| Challenge | Answer |
|-----------|--------|
| Vertical + nested scroll fight? | Remove Feed/Pump scroll after sheets |
| Stale widgets? | Write + reload on status/timer signal changes; timeline policy |
| Signing fails without paid team App Groups? | Document; tests use injectable suite; UI still ships |

## Has API / Has DB

- **Has API:** no  
- **Has DB:** no  

## Clear for Gate B?

yes — after design-review + TDD test-case review.
