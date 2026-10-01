# Analysis: phone-hig-ui

**Mode:** full  
**Has UI:** yes · **Has API:** no · **Has DB:** no  
**Grill:** yes — frontier open (Connect chrome, phone scale, tab label, Leave confirm)

## Overall

### What is this?
An iOS HIG audit + improvement pack for MyBaby Phone App: Connect, five-tab care home, Settings, and phone-facing shared care chrome — not new care features.

### Why do we need this?
Phone chrome still reads as Watch-ported / developer-facing. Parents hesitate on Connect (“API server”), compact caption chips feel small on iPhone, and “Last” is unclear. Skipping leaves a weak companion next to the Watch HIG pack.

### How to do this?
Prioritize Connect Form + copy, phone-aware chip type/spacing, clearer tab label, Settings Leave confirm. Adapt shared controls with `#if os(iOS)` / size helpers — do not fork care rules.

**Other ways:** Full phone-only care UI rewrite (rejected — M2 lock / drift). Copy-only pass (too weak for phone scale).

**Best practices:** Apple HIG tab bars, buttons, forms, typography, accessibility; reuse Phone M1–M2 shell; mirror `watch-hig-ui` pack shape.

## Deep dive by piece

### 1. Connect chrome
- **What:** Offline|Cloud entry + pairing + help.
- **Why:** Blocks all care; current title/chips feel like a console.
- **How:** `Form` + segmented `Picker` + prominent CTA; parent title (e.g. “Get started”); help/advanced secondary. Alt: keep custom chips (less system). Prefer Form/Picker.

### 2. Phone-scale care chips / headers
- **What:** Shared `TimedCareChip` / Bottle / header fonts & heights.
- **Why:** `isCompact` is chip-type, not platform — breast/pump stay caption + 44pt on iPhone.
- **How:** Platform or horizontalSizeClass: larger title font / min height on iOS; keep Watch compact. Alt: phone-only wrappers (more drift). Prefer shared platform metrics in `BabyTokens` / chip.

### 3. Tab labels + shell chrome
- **What:** TabItem titles/symbols; toolbar Retry/Settings.
- **Why:** “Last” truncates meaning; shell otherwise OK.
- **How:** Rename to **Status** (short) or **Last care** (clearer, may truncate). Prefer **Status**. Keep gear + Retry.

### 4. Settings Leave
- **What:** Destructive Leave in sheet.
- **Why:** Accidental leave → reconnect friction.
- **How:** `confirmationDialog` / alert before Leave. Alt: leave as-is (faster, riskier). Prefer confirm.

## Design tree (frontier)

### Settled
- Has API **no**, Has DB **no**
- Keep five bottom tabs + Settings sheet (M2)
- No care rule / API / widget visual redesign
- Vital few: Connect, phone-scale chips, tab clarity, Retry

### Open frontier
- N1 Connect: Form+Picker vs polish custom chips
- N2 Phone scale: shared `#if os(iOS)` metrics vs phone wrappers
- N3 Fifth tab label: Status vs Last care
- N4 Leave confirmation: yes vs no

### Blocked
- none

## Reusable patterns
- `PhoneConnectView` / `PhoneHomeView` / `PhoneSettingsSheet`
- `CarePages` + `CareControls` + `BabyTokens`
- Fail/Retry toolbar + footer (`CareFooterSlot`)
- `watch-hig-ui` incremental HIG pack approach

## System shape candidates
- Client-only SwiftUI chrome; session/care model unchanged

## Spike notes
N/A — code inspection of Connect/Home/tokens sufficient.

## Clear enough to design?
Yes after Grill settles N1–N4.
