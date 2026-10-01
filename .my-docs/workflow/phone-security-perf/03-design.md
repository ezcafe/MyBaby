# Design: phone-security-perf

**Mode:** full  
**Chosen (pending Gate B):** Option 1  
**Has UI:** yes — no IA change; Fail/Connect copy only where security requires  
**Has API:** no  
**Has DB:** no  

## Decision 2: How to remediate

### Option 1 — Targeted client harden + perf hygiene (recommended)
- **What it is:** Four Major fixes in shared code: https-except-loopback URLs; sanitize GQL Fail messages; Offline fetch limit 80 + desiredKeys; debounce widget reloads. Keep Connect/care chrome.
- **Example:** `BabyAPIConfig.normalize` rejects `http://example.com`; `applyLiveFailure` shows generic text; `fetchRecent(80)`; `WidgetReloadCoalescer`.
- **Pros:** Ships real risk cuts; small blast radius; tests fit existing Watch unit target.
- **Cons:** Does not add pinning or Keychain ThisDeviceOnly this pass.

### Option 2 — Broad hardening program
- **What it is:** Option 1 plus Keychain ThisDeviceOnly, SecureField pairing code, certificate pinning research, Instruments perf baselines.
- **Example:** Multi-week security program + memory docs.
- **Pros:** More complete.
- **Cons:** Slows day-to-day ship; pinning needs ops; out of Gate A “no extra steps” spirit for this run.

### Recommendation
**Pick Option 1** — user-first: safer URLs/errors and snappier Offline/widgets without new Connect friction.

## UI specs (Has UI)

- **Connect:** Same Offline default, segmented mode, Advanced paste hidden. Invalid URL → existing-style Fail (“Enter a valid http(s) URL” or clearer “Use https except localhost”).
- **Care:** Failed + Retry unchanged; unknown GQL errors → generic retry copy (no raw server message).
- **Widgets:** Same look; may refresh slightly later under debounce (≤1s).
- **Settings Leave:** Unchanged (still clears Keychain token).

## System design

### Overview
- Phone + Watch share `BabyCareShared` clients: Keychain token, UserDefaults base URL, CloudKit Offline, GraphQL live, App Group status DTO.
- New policy lives in `BabyAPIConfig` (+ small helper for loopback). Fail sanitization in `BabyHomeStatusModel`. Fetch caps in Offline refresh + CloudKit store. Reload coalesce beside `persistStatusForWidgets`.
- No new network endpoints. No CloudKit schema change.
- **Point to:** Sequence + OWASP below.

### Concept 1 — Trusted origin gate
Only loopback may use `http`; all other hosts require `https` before save/redeem accept.

### Concept 2 — Coalesced widget notify
App Group write is immediate; WidgetKit reload is deferred/merged.

## Design patterns used

### 1. Config normalize gate (extend existing)
- **Where:** `BabyAPIConfig.normalize` / `saveBaseURL`
- **Best practices:** One normalize path for paste, preset, and redeem result.
- **Teach:** Reject early; UI shows Fail; do not special-case only ATS.

### 2. User-safe error map (extend existing)
- **Where:** `applyLiveFailure` / `pairUserMessage`
- **Best practices:** Known codes stay specific; unknown → generic.
- **Teach:** Never assign raw `graphQL.message` to `statusFail`.

### 3. Coalescer for side effects
- **Where:** new small helper used by `persistStatusForWidgets`
- **Best practices:** Cancel/replace pending reload Task; save DTO first.
- **Teach:** Debounce notifications, not data writes.

## Sequence

```text
Cloud paste/redeem URL
  → normalize (https | loopback http)
  → save baseURL + Keychain token
  → live GraphQL
  → on GQL error: map to safe statusFail (+ Retry)

Offline refresh
  → fetchRecent(limit: 80, desiredKeys: CareEvent fields)
  → map snapshot → App Group save
  → schedule coalesced WidgetCenter.reloadTimelines
```

## API contracts

**N/A** — no public contract change. Still `POST …/api/graphql/baby` and `POST …/api/watch/pair/redeem`.

## Database contracts

**N/A** — CloudKit `CareEvent` fields unchanged. Query uses lower `resultsLimit` + `desiredKeys`.

### Example queries (CloudKit)

```text
CKQuery CareEvent predicate TRUE
sort at DESC
resultsLimit 80
desiredKeys: kind, at, schemaVersion, side, ml, diaperKind, durationSec
```

## OWASP (mobile client)

| OWASP | Status | Note |
|-------|--------|------|
| A01 Broken Access | ok | Token Bearer unchanged; Leave clears |
| A02 Crypto failures | target | https-except-loopback; Keychain stays |
| A03 Injection | ok | No new query composition |
| A04 Insecure design | target | Sanitize GQL messages |
| A05 Misconfig | target | Align policy with ATS exceptions |
| A06 Vulnerable comps | n/a | |
| A07 Auth failures | ok | pairUserMessage already safe |
| A08 Integrity | ok | |
| A09 Logging | ok | Do not log tokens |
| A10 SSRF | soft | Client origin gate reduces odd http bases |

**Trust boundaries:** Keychain vs App Group vs CloudKit vs network.  
**Abuse:** paste evil http URL; GraphQL error with token-like message; Offline history growth.

## Non-goals

- Certificate pinning; Watch-only UI; server schema; Keychain ThisDeviceOnly (unless Gate B expands).

## Risks

- Shared changes affect Watch — run existing unit tests.
- Limit 80 might miss rare multi-event overlay needs — revisit if status gaps appear.
