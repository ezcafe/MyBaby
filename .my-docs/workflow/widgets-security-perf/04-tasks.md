# Tasks: widgets-security-perf

**Design option:** Option 1 (pending Gate B)  
**TDD:** yes — failing unit tests before production changes

## Task 1 — Honest empty mailbox snapshot

- **Acceptance:** `BabyHomeStatusSnapshot` exposes `emptyForWidgets` (no running timers; last-care lines empty so `BabyCareComplicationDisplay.resolve` → `.empty`). `BabyCareStatusStore.snapshotForWidgets` returns that when load fails. `apply(dto:onto:)` uses empty base (not `sampleNextFeed`). Placeholder / `isPreview` paths still use samples.
- **Tests (TDD):**
  - Unit: empty suite → `snapshotForWidgets` resolves to `mode.empty` (not nextFeed sample).
  - Unit: empty primary / accessibility still “No care yet”.
  - Update/replace `statusStoreEmptyFallsBackForWidgets` expectations.
- **Files:** `BabyCareShared/BabyHomeStatusSnapshot.swift`; `BabyCareShared/BabyCareStatusStore.swift`; `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift`.

## Task 2 — Secondary-line privacySensitive

- **Acceptance:** Phone + Watch widget views mark **secondary** Text that shows care relative ages / overdue care-time copy with `.privacySensitive()` (in addition to existing primary). Empty chrome copy may stay clear.
- **Tests:** Build/visual; unit optional N/A (SwiftUI modifier). Note smoke checklist: Lock Screen redaction.
- **Files:** `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift`; `MyBaby Watch Widgets/BabyCareWidgets.swift`.

## Task 3 — Mailbox secrets boundary verify

- **Acceptance:** Existing `statusStoreDTOExcludesTokenKeys` stays green; no widget code path reads Keychain or starts URLSession. Entitlements remain App Group only.
- **Tests (TDD):** Keep/extend forbidden-key unit if gaps; grep smoke in test log.
- **Files:** `BabyCareStatusStore.swift` (if needed); tests only otherwise.

## Task 4 — Timeline + coalescer verify-only

- **Acceptance:** No change to 750ms delay or `BabyCareWidgetTimeline.nextUpdate` numbers. Existing nextUpdate + coalescer unit tests stay green; add brief comment in coalescer or timeline pointing to policy (timer → 15m horizon; idle next-feed boundary; else 15m).
- **Tests (TDD):** Confirm existing timeline + coalescer tests; add only if a case is missing (document in task notes).
- **Files:** `BabyCareWidgetTimeline.swift` and/or `WidgetTimelineReloadCoalescer.swift` (comments); tests as needed.

## Task 5 — Smoke closeout

- **Acceptance:** Phone WidgetsExtension + Watch Widgets / Watch App **BUILD SUCCEEDED**; unit suite green including Task 1 tests.
- **Tests:** Run Watch AppTests + widget builds; record in `06-test-log.md`.

## Out of scope tasks

- Changing coalesce delay / nextUpdate intervals
- HIG layout / overdue / a11y redesign
- Live Activities; interactive widgets
- App Connect ATS / Keychain hardening
