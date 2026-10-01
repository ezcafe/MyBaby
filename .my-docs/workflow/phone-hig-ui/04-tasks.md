# Tasks: phone-hig-ui

**Mode:** full · **Has UI:** yes · **Has API:** no · **Has DB:** no  
**Design:** Option 1 — incremental iOS HIG pack

## Task 1 — Connect Form + parent copy

- **Do:** Rebuild `PhoneConnectView` with Form/List, segmented Offline|Cloud, “Get started” title, prominent CTA, help/advanced secondary. Keep preset/pairing/session calls.
- **Acceptance:** No “API server” chrome; Offline default; Cloud code path works; help collapsed by default.
- **Tests (TDD):** Unit — Connect view model/helpers if extracted (preset selection unchanged). UI: manual Connect Offline + Cloud fields visible. Prefer unit on any new pure copy/layout helper.

## Task 2 — Shared iOS care metrics

- **Do:** Add platform font/height helpers on `BabyTokens`; wire `TimedCareChip`, Bottle/Pump entry, `CareSectionHeader` secondary/lead on iOS; watchOS unchanged visually.
- **Acceptance:** iOS compact chips use larger type / ≥44pt; Watch Feed L/R still compact caption-scale; no care rule changes.
- **Tests (TDD):** Unit tests for token helpers (`#if` / expected sizes) if pure functions; else document simulator check Watch + iPhone.

## Task 3 — Tab label Status + Leave confirm

- **Do:** Rename Last tab to **Status**; add Leave `confirmationDialog` in `PhoneSettingsSheet`.
- **Acceptance:** Tab shows Status; Leave asks confirm; Cancel keeps session; Confirm leaves → Connect.
- **Tests (TDD):** Unit/UI test if existing Phone tests host Settings; else manual + any XCTest for sheet if present.

## Task 4 — Smoke both platforms

- **Do:** Build Phone scheme; build Watch scheme (or Watch unit target) to ensure shared edits compile.
- **Acceptance:** Phone + Watch compile; Connect → Feed log path still works on Phone simulator.
- **Tests (TDD):** `xcodebuild` Phone + Watch (or documented pair) green.

## Order

1 → 2 → 3 → 4 (2 can parallel 1 after tokens stub exists)

## Out of scope tasks

- Widget redesign, NavigationSplitView, hiding CareSectionHeader lead, API/DB work
