# Analyze: phone-m2-care-home

## Overall deep dive

1. **What is this?** Phone care home that logs feed / sleep / diaper / pump after M1 Connect, matching Watch quick-care behavior and my-apps BABY_API §4.
2. **Why do we need this?** Without chips, Phone cannot do the caregiver’s daily job; M1 shell alone stalls the care-first ladder.
3. **How to do this?** Reuse Watch `BabyHomeStatusModel` + care pages against `PhoneSessionModel` live/offline clients; adapt navigation for iPhone. Alternatives: rewrite Phone-only model (more drift risk); call simple mutations only (weaker than §4). Best practice: one model, one rule set, platform layout only.

## Solution pieces (≤5)

### 1. Wire session → care model
- **What:** After Connect, Phone home owns a care model fed by `graphQLClient` or `offlineStore` from `PhoneSessionModel`.
- **Why:** Status/writes need the same session M1 already established.
- **How:** Init/bind model on appear; `useLive` / `useOffline` already set clients. Other ways: duplicate session fields into model (worse). Best: inject clients into shared model API.

### 2. Live quick-care path
- **What:** `babyHomeQuickStatus` load + `babyQuickCare` sends with `clientRequestId` + retry-same-id.
- **Why:** BABY_API §4 is the Watch/web contract.
- **How:** Reuse `BabyGraphQLDocuments` + model `sendQuickCare` / `retryLastFailure`. No new endpoints.

### 3. Offline append path
- **What:** CareEvent append + recent fetch for status-like UI.
- **Why:** Offline caregivers must log without GraphQL.
- **How:** Existing `CloudKitOfflineCareStore` used by Watch model offline branches.

### 4. Care UI on iPhone
- **What:** Feed / Sleep / Diaper / Pump / Last care surfaces with fail/retry chrome.
- **Why:** Day-to-day logging is the M2 outcome.
- **How:** Port `CarePages` + controls; choose Phone navigation (grill). Tokens: Watch uses `BabyTokens` — Phone needs shared or local equivalent.

### 5. Fail / retry chrome
- **What:** Chip “Failed” + Retry reuses id; status-load fail reloads.
- **Why:** Silent fail is the top usability risk.
- **How:** Reuse `CareFailedControl` + footer Retry from Watch home.

## Spike notes

- `BabyHomeStatusModel` imports WidgetKit + SwiftUI; WatchKit only under `#if os(watchOS)` — **can compile for iOS** if added to Phone / Shared.
- Care pages hard-depend on `BabyTokens` (Watch Theme) — Phone must share tokens or duplicate constants.
- `persistStatusForWidgets` reloads Watch complication kind — on iPhone harmless or no-op if kind absent; M3 will add Phone widgets later.

## Reusable patterns

| Pattern | Where |
|---------|--------|
| Quick-care send + retry | `BabyHomeStatusModel` |
| Page ids / deep links | `BabyCareShared/BabyHomePage.swift` |
| Status map | `BabyHomeStatusMapper` |
| Phone session | `PhoneSessionModel` |
| Connect/Settings shell | M1 Phone views |

## System shape candidates

1. **Compile Watch model + pages into Phone target** — fastest parity; theme coupling.
2. **Move model to BabyCareShared; Phone-specific views** — cleaner boundary; more move work.
3. **Phone-only thin model calling shared GraphQL/Offline** — highest drift risk.

Recommend **1 for M2** (parity speed), extract to Shared if compile friction appears.

## Design tree (frontier)

| ID | Decision | Depends on | Status |
|----|----------|------------|--------|
| N1 | Phone navigation (bottom tabs vs vertical pages vs scroll) | — | open |
| N2 | Model sharing strategy (compile Watch vs move Shared) | — | open |
| N3 | Diaper dirty detail in M2? | — | open (idea default yes) |
| N4 | Last care: fifth tab vs header strip | N1 | open |

## Has API / Has DB (refine)

- **Has API:** **no** — consume existing GraphQL; no new contracts.
- **Has DB:** **no** — existing CareEvent schema; no migration.

## Enough to design?

**yes** — after Grill settles N1–N4.
