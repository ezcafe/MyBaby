# Design: phone-m2-care-home

**Mode:** full  
**Has API:** no · **Has DB:** no  
**Updated:** 2026-09-30  
**Grill:** frontier-empty (02b) — N1 bottom tabs · N2 share Watch model · N3 diaper detail · N4 last-care tab

## Decision 1: Care UI delivery on Phone

### Option 1 — Reuse Watch care model + page views; Phone bottom TabView shell (recommended)

- **What it is:** Compile `BabyHomeStatusModel` + `CarePages` / controls / tokens into the Phone app (or thin Shared move if needed). Replace `PhoneHomeView` placeholder with a bottom `TabView` hosting Feed / Sleep / Diaper / Pump / Last care. Wire model from `PhoneSessionModel` clients.
- **Example:** `PhoneHomeView` → `TabView { FeedPage; SleepPage; … }` bound to one `BabyHomeStatusModel` filled from session offline/live.
- **Pros:** Same rules, fail/retry, diaper sheet; fastest parity; Gate A #1/#2 preserved.
- **Cons:** Watch Theme (`BabyTokens`) must compile on iOS; some Watch layout tweaks.

### Option 2 — New Phone-only care UI calling thin shared send helpers

- **What it is:** Extract only GraphQL/Offline send helpers; design new iPhone screens from scratch.
- **Example:** New `PhoneCareView` with custom chips calling `sendQuickCare` helper.
- **Pros:** Phone-native look freedom.
- **Cons:** High drift vs Watch/web; longer M2; fail/retry easy to miss.

### Recommendation

**Pick Option 1** — grill N1–N4; user-first identical care behavior.

## Chosen design (locks)

### Shell

1. Keep M1 Connect / Settings / Leave.
2. Replace placeholder with care `TabView` (bottom tabs): Feed, Sleep, Diaper, Pump, Last care.
3. Toolbar: status loading indicator; Retry when `lastFailedControl` or `statusFail`; Settings gear → existing `PhoneSettingsSheet` (or Watch Settings sheet adapted — prefer keep Phone Settings leave path).

### Model wiring

1. Add Watch care model (+ CarePages, CareControls, BabyTokens, CarePageBackgroundFill as needed) to **Phone target membership** (or Shared if compile requires).
2. On connected home appear: create/bind `BabyHomeStatusModel` with `mode` / `graphQLClient` / `offlineStore` from `PhoneSessionModel`.
3. Live: `loadLiveStatus()` on appear / mode change.
4. Offline: offline append paths already in model; refresh from store after writes.
5. `persistStatusForWidgets()` may run (App Group snapshot); Phone widgets UI still M3.

### Care behavior (parity)

| Action | Live | Offline |
|--------|------|---------|
| Breast L/R timer | `babyQuickCare` BREAST + running payload | CareEvent append |
| Formula / bottle ml | FORMULA | CareEvent ml |
| Sleep toggle | SLEEP start/end | CareEvent sleep |
| Diaper ± detail | DIAPER (+ sheet fields) | CareEvent diaperKind |
| Pump L/R / amount | pump_* / PUMP_AMOUNT | CareEvent |
| Fail | chip Failed + Retry same `clientRequestId` | user-visible fail; no false OK |

### UI specs (Has UI)

- **#1** Care chips on selected tab always visible.
- **#2** Running timer / open nap title state always visible on that tab.
- Hit targets ≥44pt; reuse Watch chip heights where sensible on Phone.
- Fail subtitle copy: `Failed` (Watch `CareControlLabels`).
- Secondary: diaper detail sheet; Settings; mode via Settings.

## System design

### Overview

- **Runtime:** Phone App process → SwiftUI care TabView → `BabyHomeStatusModel` → either `BabyGraphQLClient` (live) or `OfflineCareStoring` (offline).
- **Boundaries:** No new HTTP surface; session auth stays in `PhoneSessionModel` / Keychain; care model never stores token in App Group.
- **Ownership:** UI + model orchestration in Phone (+ shared Watch sources); contracts owned by my-apps BABY_API; CloudKit schema unchanged.
- See Sequence + API/Database contracts below (no restatement).

### Concept N/A

No new service concept — companion client only.

## Design patterns used

### 1. Observable session + care model

- **What:** `@Observable` session (M1) injects clients into `@Observable` care model (Watch).
- **Why:** Matches existing Watch/Phone Observation style.
- **Where:** `PhoneSessionModel`, `BabyHomeStatusModel`.

### 2. Idempotent clientRequestId retry

- **What:** Unknown/network fail keeps same id on Retry.
- **Why:** BABY_API §10 / Watch tests.
- **Where:** `BabyClientRequestId.retrySame`, `retryLastFailure`.

### 3. Platform shell, shared care pages

- **What:** Phone owns TabView shell; pages/controls shared from Watch sources.
- **Why:** Grill N1 Option 2 + N2 Option 1.
- **Where:** `PhoneHomeView` + `CarePages.swift`.

## Sequence

```text
User opens Phone (connected)
  → PhoneHomeView mounts BabyHomeStatusModel(session clients)
  → if live: loadLiveStatus (babyHomeQuickStatus)
  → User taps breast Left → timer runs
  → User stops → sendQuickCare / offline append
  → success: refresh status / local snapshot
  → fail: lastFailedControl + Retry toolbar
  → Retry → same clientRequestId
```

## API contracts

**Has API: no** (consume existing).

| Op | Document | Notes |
|----|----------|-------|
| Status | `BabyGraphQLDocuments.homeQuickStatus` | dayFrom/dayTo local window |
| Write | `BabyGraphQLDocuments.quickCare` | action + clientRequestId |

No new fields. Errors: NOT_FOUND / CONFLICT / network → existing model mapping.

## Database contracts

**Has DB: no** (existing CareEvent).

| Store | Type | Fields used |
|-------|------|-------------|
| CloudKit private | `CareEvent` | kind, at, side?, ml?, diaperKind?, durationSec?, schemaVersion=1 |

Example: breast stop Offline → `append(CareEvent(kind: "feed", side: "breast_l", durationSec: …))`.

## OWASP / security notes

- Token only Keychain (M1 lock).
- App Group snapshot = status only (no token).
- No logging of pairing codes / tokens in care path.
- Validate ml / enum client-side as Watch does; server remains source of truth live.

## Acceptance

- [ ] Placeholder removed; 5 tabs usable Offline + live
- [ ] Breast / bottle / sleep / diaper(+detail) / pump paths work
- [ ] Live fail → Failed + Retry same id
- [ ] Offline fail visible
- [ ] Settings Leave → Connect
- [ ] Unit tests for wired model paths; build Phone App green
- [ ] No widgets UI; no new API/schema

## Rejected alternative (short)

Option 2 Phone-only UI — deferred; too much rule drift for M2.
