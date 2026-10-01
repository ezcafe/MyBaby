# Design: phone-hig-ui

**Mode:** full  
**Has API:** no · **Has DB:** no  
**Grill:** frontier-empty — N1 Form Connect · N2 shared iOS metrics · N3 Status tab · N4 Leave confirm  
**Note:** main-thread fallback — usage limit

## Decision 1: which design approach?

### Option 1 — Incremental iOS HIG pack on current Phone shell (recommended)

- **What it is:** Keep Connect → TabView care → Settings sheet. Fix Connect to Form/Picker + parent copy; add iOS metrics in shared tokens/chips; rename Last → Status; confirm Leave. No API/DB/rule changes.
- **Example:** Connect title “Get started”; Offline|Cloud segmented; breast chips use `.subheadline`/taller min height on iOS only.
- **Pros:** Matches Gate A vital few; small blast radius; Watch protected via `#if os`.
- **Cons:** Shared file edits need Watch smoke check.

### Option 2 — Phone-only care UI fork

- **What it is:** New phone pages/controls; leave Watch shared as-is.
- **Example:** `PhoneFeedPage` with `List`/`Button` styles separate from `FeedPage`.
- **Pros:** Maximum iOS freedom.
- **Cons:** Drift vs Watch/web; large rewrite; rejects M2 reuse lock.

### Recommendation

**Pick Option 1** — user-first HIG wins without forking care.

## Chosen design (Option 1 locks)

### Connect (`PhoneConnectView`)

- Replace ad-hoc `ScrollView` stack with `Form` (or `List` + inset grouped).
- Title: **Get started** (not “API server”); optional subtitle: “Save care on this iPhone and Watch.”
- Offline | Cloud: `Picker` `.segmented` (keep preset selection logic).
- Offline helper text under picker; Cloud: URL field when needed + Pairing code.
- Primary: `Start Offline` / `Save & connect` — `.borderedProminent`, tint teal, disabled while connecting.
- Errors: `Section` footnote / `.foregroundStyle(.red)` — keep existing fail strings.
- **Need help?** disclosure / button → steps; Cloud **Advanced** paste URL & token stays secondary.
- Accessibility: labels on fields; selected segment traits.

### Care home shell (`PhoneHomeView`)

- Keep five tabs; fifth label **Status** (`list.bullet` OK).
- Toolbar: loading `ProgressView`; **Retry** when fail; gear → Settings.
- Keep single `NavigationStack` wrapper for now (M2); do not invent per-tab stacks this pack.
- Optional: soft page background via existing `CarePageBackgroundFill` if already compiles on iOS — only if zero layout risk; else skip.

### Shared phone scale (`BabyTokens` / `CareControls` / `CarePages`)

- Add platform metrics, e.g. `BabyTokens.careTitleFont` / `secondaryFont` / chip min height:
  - **watchOS:** keep caption / caption2 / 44pt compact behavior.
  - **iOS:** compact chips use at least `.subheadline.weight(.semibold)` (or `.body` for nap); secondary `.footnote` or `.subheadline`; min height ≥44 (prefer ~52 for compact rows if it still fits).
- `TimedCareChip`: use platform metrics instead of hard `.caption` for compact iOS.
- Bottle / Pump amount entry buttons: same phone height/font rules.
- `CareSectionHeader`: on iOS prefer `.title3`/`.headline` lead; consider hiding redundant lead when tab already names the page **or** keep lead but increase type — prefer **keep lead**, larger type (less IA change).
- `#if os(watchOS)` / `#if os(iOS)` only — no behavior change to taps/rules.

### Settings (`PhoneSettingsSheet`)

- Keep List + Done.
- **Leave** → `confirmationDialog` (“Leave Offline/Cloud? You’ll need to connect again.”) Confirm / Cancel.
- Mode + iCloud rows unchanged.

### Out of pack

- Widget visuals, new tabs, NavigationSplitView, care rule changes, ConnectHostURLField logic changes beyond presentation.

## UI specs (Has UI) — Gate A alignment

| # | Spec |
|---|------|
| 1 | Primary care controls always visible on selected tab |
| 2 | Tab bar + Connect primary CTA always visible on their screens |
| Hit | ≥44pt all primary controls |
| A11y | VoiceOver labels on Connect fields, tabs, Retry, Settings, Leave confirm |
| Type | Dynamic Type: prefer text styles over fixed caption2 on iOS |

## System design

### Overview

- **Runtime:** Phone App SwiftUI only — Connect / TabView / Settings; shared care views render with platform tokens.
- **Boundaries:** No new HTTP/CloudKit; session + care model ownership unchanged.
- **Ownership:** Phone shell files own Connect/Settings chrome; `BabyCareShared` owns cross-platform metrics.
- API/DB contracts: **N/A**.

### Concept N/A

No new service.

## Design patterns used

### 1. Platform metrics in shared tokens

- **What:** `#if os` font/height helpers on `BabyTokens` consumed by chips/pages.
- **Why:** One care UI, two densities — avoids phone fork.
- **Where:** `BabyTokens.swift`, `CareControls.swift`, `CarePages.swift`.

### 2. System Form + segmented picker

- **What:** iOS Form/Picker for mode choice; prominent button for commit.
- **Why:** Matches HIG Forms / Buttons; parent-readable.
- **Where:** `PhoneConnectView.swift`.

### 3. Confirmation before destructive Leave

- **What:** `confirmationDialog` before `session.leave()`.
- **Why:** HIG destructive actions; reduces accidental disconnect.
- **Where:** `PhoneSettingsSheet.swift`.

## Sequence

```text
Cold start → restore session
  → if not connected: Connect Form (Offline default) → Start Offline / Save & connect
  → PhoneHome TabView (Feed default)
  → tap care chip → model send (unchanged)
  → on fail: toolbar Retry
  → Settings → Leave → confirm → Connect again
```

## API contracts

N/A — no public contract change.

## Database contracts

N/A — no schema/query change.

## OWASP (UI / client)

| Item | Note |
|------|------|
| A01 | Leave clears session; no new authz surface |
| A02 | Token still Keychain / advanced paste only — not logged |
| A04 | Confirm Leave reduces accidental session drop |
| A05 | No new security misconfig |
| Others | N/A / unchanged for chrome-only |

## HIG gap → fix map (audit summary)

| Gap vs Apple HIG / best practice | Fix in this pack |
|----------------------------------|------------------|
| Connect title “API server” (jargon) | Parent “Get started” + helper |
| Custom mode chips vs segmented control | `Picker` `.segmented` in Form |
| Ad-hoc ScrollView form | `Form` / grouped List |
| Compact `.caption` chips on iPhone | iOS metrics in shared tokens |
| Tips use Watch `caption2` on phone | iOS secondary text style |
| Tab “Last” unclear | **Status** |
| Leave destructive without confirm | `confirmationDialog` |
| Duplicate section header vs tab (minor) | Larger type; keep lead (no hide this pack) |
| NavStack wrapping TabView (minor) | Defer — not vital few |

## Rejected alternative (≤3 lines)

Option 2 phone-only fork — better visual freedom, but duplicates care UI and breaks M2 parity; reject.
