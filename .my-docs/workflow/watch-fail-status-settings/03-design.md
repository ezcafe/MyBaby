# Design: Chip fail status + Settings logout + connect guide

**Mode:** full

## Decision 1: where does chip fail state live?

### Option 1 — Model-owned `lastFailedControl` (recommended)

**What it is:** `BabyHomeStatusModel` records which control last failed on live send; chips/grids read it for fail chrome. Settings + logout + connect guide as separate page/UI.

**Example:** `selectBottle(90)` → network fail → `lastFailedControl = .bottle(ml: 90)` → that ml chip shows “Failed”; footer still has short reason.

**Pros:** Testable; one source of truth with `statusFail`; matches footer model pattern.  
**Cons:** Need a small control-id enum covering timed + amount + diaper.

### Option 2 — View-local error flags

**What it is:** Each page sets `@State failedMl` on catch via callbacks.

**Example:** FeedPage sets `failedBottleMl = 90` when model publishes a fail event.

**Pros:** Less model surface.  
**Cons:** Easy to desync from footer; harder unit tests; retries across pages weaker.

### Recommendation

**Pick Option 1** — keep fail state next to `statusFail` / `applyLiveFailure`.

## Chosen design

Option 1 + Gate A2 HTML lock:

- Chip fail chrome (danger); copy **Failed**
- Settings last page: host + **Log out** only
- Logout → clear token → `isConnected = false` → Connect; **must** connect before care; **no** Continue with sample on connect
- Quick connect guide **at bottom** of `AuthConnectView`
- Status-load fail (no chip): footer only
- Keep toolbar gear → open connect without logout (re-pair while logged in)

**Build must match** `ui-refs/_proposed-feed-chip-fail.html`, `_proposed-settings.html`, `_proposed-connect-guide.html`.

## System design

### Overview

- **Boundaries:** Watch UI → model → existing GraphQL client; logout only clears local Keychain + mode. No server API change.
- **Ownership:** Model owns fail control + connection mode; Views render chip/Settings/Connect.
- **Failure domain:** Network/auth → chip fail + footer; auth hard fail may still set `needsReconnect` (opens connect). Logout always forces connect.
- **Scale:** Single user Watch.

### Concept 1 — Failed control identity

- **What:** Enum covering timed sides, bottle/pump ml, diaper kind.
- **How:** Set in `sendQuickCare` catch after knowing which action; clear on success / new action on that control.
- **Why:** HTML shows fail on the specific chip.

## Design patterns used

### Pattern 1 — Observable model state

- Chips bind to model phases + `lastFailedControl` (same as done-flash pattern).

### Pattern 2 — Auth gate

- `ContentView` already switches on `isConnected`; logout sets false.

### Pattern 3 — Neighbor TabView mount

- Extend `BabyHomePage` + `shouldMount` for `.settings` (rawValue 5).

## Sequence diagram

```mermaid
sequenceDiagram
  actor User
  participant Chip as Care chip
  participant Model as BabyHomeStatusModel
  participant API as GraphQL baby
  participant Settings as SettingsPage
  participant Connect as AuthConnectView
  participant Store as BabyAPITokenStore

  User->>Chip: log / stop
  Chip->>Model: select*/toggle*
  Model->>API: babyQuickCare
  API-->>Model: error
  Model->>Model: statusFail + lastFailedControl
  Note over Chip: shows Failed

  User->>Settings: Log out
  Settings->>Store: clear()
  Settings->>Model: disconnect (isConnected=false)
  Settings->>Connect: show (gate)
  Note over Connect: guide at bottom; must Save and connect
```

## API contracts

**Has API = no.** Consumes existing `babyQuickCare` / status only.

## Database contracts

**Has DB = no.**

## UI / UX / mobile

- Match approved HTML: size, positions, texts, chrome.
- Chip fail: danger border/text; title or label **Failed**.
- Settings: “Settings”, “Connected · {host}”, Log out.
- Connect: existing controls first; Quick connect guide below primary button; no sample CTA.
- Footer `statusFail` remains backup; wire **Retry** on footer to `retryQuickCare` when id known (nice-to-have if time).

## OWASP (client)

| Item | Notes |
|------|-------|
| Secrets | Logout must `clear()` Keychain; never log token |
| Auth | Care gated on `isConnected` |
| Input | Pairing code validation unchanged |

## Aggressive challenges

- Fail on done-flash race: clear fail when scheduling new done, or prefer fail over done until cleared.
- Timed stop fail: show fail on that timed chip (phase `.failed` or overlay).
- Removing sample may hurt first-run demos — Gate A2 accepted; previews use `bypassAuth`.

## Success criteria (design)

- [ ] Fail visible on trigger chip per HTML
- [ ] Settings last; Log out only
- [ ] Logout → Connect with bottom guide; no care until connected
- [ ] Unit tests for page order, fail mapping, logout clear
