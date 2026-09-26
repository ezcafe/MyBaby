# Design: Watch UI improvements

**Mode:** full  
**Note:** main-thread fallback — usage limit  
**Build lock:** Match approved `ui-refs/_proposed-feed-fail-retry.html`, `_proposed-settings-sheet.html`, `_proposed-connect-presets.html` (size, positions, texts, chrome).

## Decision 1: which design approach?

### Option 1 — Model-owned retry + gear sheet (recommended)

**What it is:**  
Extend `BabyHomeStatusModel` with last quick-care payload + `isStatusLoading`; Views only bind. Settings becomes `SettingsSheet` from gear; remove Settings TabView page.

**Example:**  
Fail bottle → chip shows `90 ml` / `Failed` → footer Retry → `retryQuickCare` with stored input. Gear → sheet → Log out (confirm) → Connect gate.

**Pros:**

- Matches approved HTML and existing Observable model
- True Retry with same `clientRequestId`
- Clear separation: strip = care only

**Cons:**

- More model fields/tests
- Enum/deep-link updates for settings

### Option 2 — View-local recovery + fullScreenCover Settings

**What it is:**  
Retry reconstructed only from `lastFailedControl` in Views; Settings as `fullScreenCover` without storing send payload.

**Example:**  
Failed breast stop retries without duration → wrong API or no-op.

**Pros:**

- Slightly less model surface

**Cons:**

- Incomplete Retry for timed stops
- Weaker HTML parity for sheet vs cover

### Recommendation

**Pick Option 1** — correct Retry + sheet matches Gate A2.

## Chosen design (Option 1)

### Fail + Retry

- Fail title = identity (`Left`, `90 ml`, diaper kind); subtitle = `Failed` (no blank `" "` hack).
- Model: `lastQuickCarePayload` (action + optional breastRunning + clientRequestId) on fail; clear on success.
- Care pages: `CareFooterSlot(..., onRetry: { Task { await model.retryLastQuickCare() } }, onDiscard: … when recovery)`.
- Failed chip tap = same retry path.
- Status-load fail (no chip): footer Retry → `loadLiveStatus()`.

### Live loading

- `isStatusLoading` true around `loadLiveStatus`; optional `isSending` for send — prefer status loading for HTML “Updating…”.
- Show muted “Updating…” under `CareSectionHeader` when loading (all care pages or shared wrapper).

### Settings Option B

- Remove `BabyHomePage.settings` from TabView (and enum if safe); update `shouldMount` tests; strip = 5 pages.
- Deep link `page=settings` → open settings sheet (flag on model or callback), not a page.
- Gear: present sheet (not Connect). Sheet: host line, Log out (`.confirmationDialog`), Reconnect → dismiss + `showConnect = true`.
- Delete or stop using `SettingsPage` in TabView.

### Connect / polish

- Preset buttons `.frame(height: BabyTokens.careChipHeight)`.
- Errors: `p.danger` not `.red`.
- Secondary font: system `.caption2` (drop 10pt diaper/connect guide).
- Ml chips: `"\(ml) ml"`.
- Pump: header detail = status cue if any; footer tip = `pumpTip` only (no duplicate).
- Last care: `lineLimit(2)`.
- Accessibility labels on chips.

### Widgets

- Out of Build scope this pass (defer).

## System design

### Overview

- Watch UI only; no new HTTP/GraphQL contracts.
- Runtime: `ContentView` auth gate → `BabyHomeView` TabView (5 care pages) + toolbar gear → `SettingsSheet`; Connect stays separate.
- Fail/retry state lives on `@Observable` model shared by pages.
- Point to Sequence + OWASP below for auth logout/reconnect — do not duplicate.

### Concept 1 — Session sheet vs care strip

Care jobs stay in horizontal pages; rare session actions (host, logout, reconnect) live in a modal sheet so Last care stays easy to reach.

## Design patterns used

### 1. Observable single source of truth

**What:** UI state (phases, fail, loading, last payload) on one model.  
**How:** Views bind; async send/load updates flags.  
**Why:** Pages share footer/fail without props drilling.  
**Best practices:** Clear fail/loading on success paths; cancel done-flash Tasks as today.

### 2. Progressive disclosure (sheet)

**What:** Secondary session UI behind gear.  
**How:** `.sheet` + confirmationDialog.  
**Why:** Matches Option B / Gate A.  
**Best practices:** Destructive Log out needs confirm.

## Sequence diagram

```mermaid
sequenceDiagram
  participant U as Parent
  participant V as CarePage
  participant M as BabyHomeStatusModel
  participant API as GraphQL

  U->>V: Tap chip / Retry
  V->>M: selectBottle / retryLastQuickCare
  M->>API: babyQuickCare
  alt fail
    API-->>M: error
    M->>M: lastFailedControl + payload + statusFail
    M-->>V: Failed subtitle + Retry
  else ok
    API-->>M: ok
    M->>M: clear fail; loadLiveStatus
    M-->>V: Done flash / updated snapshot
  end

  U->>V: Gear
  V->>V: SettingsSheet
  U->>V: Log out (confirm)
  V->>M: logout()
  V->>V: show Connect
```

## API contracts

**N/A** — no public contract change. Reuse `babyQuickCare` / `babyHomeQuickStatus`.

## Database contracts

**N/A**

## Example queries

**N/A** (existing GraphQL docs in my-apps `docs/BABY_API.md`).

## UI / UX / mobile

- Align Gate A #1/#2: chip identity + Retry; secondary in sheet.
- **Build must match** approved HTML ui-refs.
- Hits ≥44pt; confirm logout; muted Updating…; danger token.

## OWASP (relevant)

| Topic | Apply |
|-------|--------|
| A01 Broken access | Logout clears token (existing); reconnect via Connect |
| A07 Auth failures | Unauthorized → needsReconnect + sheet Reconnect / Connect |
| Secrets | Token stays Keychain; sheet shows host only not token |

## Aggressive challenges

| Challenge | Response |
|-----------|----------|
| Retry without payload? | Store last payload — Option 1 |
| Keep settings enum? | Prefer remove page; deep link opens sheet |
| Widgets this pass? | No — deferred |

## Has API / Has DB

- **Has API:** no  
- **Has DB:** no  
