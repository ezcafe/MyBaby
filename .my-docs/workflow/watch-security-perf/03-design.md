# Design: watch-security-perf

**Mode:** full  
**Chosen (pending Gate B):** Option 1  
**Has UI:** yes — no IA change; Gate A #1/#2 locked  
**Has API:** no  
**Has DB:** no  
**Grill:** ATS Phone-parity · Leave **keep** base URL · defer Enhancements (do not reopen)

## Decision 1: How wide is Watch remediation?

### Option 1 — Verify shared + Watch ATS only (recommended)

- **What it is:** Treat phone-security-perf Majors in `BabyCareShared` as done (URL gate, Fail copy, Offline 80+desiredKeys, WidgetTimelineReloadCoalescer). Ship Watch-only ATS loopback exceptions in `Config/WatchApp-Info.plist`. Leave clears Keychain token + mode; **keeps** saved base URL. Defer Keychain ThisDeviceOnly, pairing SecureField, HTTP Fail scrub.
- **Example:** Copy Phone `NSExceptionDomains` for `127.0.0.1` + `localhost` (`NSExceptionAllowsInsecureHTTPLoads`) into Watch Info; extend logout unit to assert base URL still present after Leave.
- **Pros:** Hits Watch Major ATS gap; no double-work on shared; faster Cloud reconnect after Leave (human pick); small blast.
- **Cons:** Leave weaker than Phone on origin clear; Enhancements stay open.

### Option 2 — Broad Watch harden + Phone Leave parity

- **What it is:** Re-touch shared helpers “for Watch,” call `clearBaseURL` on logout, and ship deferred Enhancements now.
- **Example:** Keychain ThisDeviceOnly migration + SecureField pairing + scrub `"HTTP \(code)"` + clear origin on Leave.
- **Pros:** Closer Phone/Watch session parity; more hardening.
- **Cons:** Reopens grill; risks reconnect friction; duplicate shared work already green.

### Recommendation

**Pick Option 1** — user-first: local Cloud Connect works on wrist without redoing shared fixes; Leave stays intentional on token while keeping host for fast re-pair.

## UI specs (Has UI) — Build lock

| Surface | Spec |
|---------|------|
| Care pages | #1 Care actions + status/timer (or Failed + Retry) always visible — unchanged hierarchy |
| Connect | #2 Offline default + primary Start Offline / pair — unchanged IA |
| Fail / Retry | Keep visible; use existing `BabyLiveStatusFailCopy` (no raw GQL); `"HTTP \(code)"` OK this pass |
| Settings Leave | Clears token + disconnects; **does not** clear saved base URL; Connect Offline default still shows |
| Complications | Status mailbox only; no chrome redesign |
| Secondary | Advanced paste / Need help stay secondary |

## System design

### Overview

- Watch App + Widgets share `BabyCareShared` with Phone: Keychain token, UserDefaults base URL, CloudKit Offline, GraphQL live, App Group status DTO.
- **Ship delta:** Watch ATS exception domains (Phone-parity) in `Config/WatchApp-Info.plist`. Shared URL/Fail/Offline/coalescer = **verify only**.
- Leave: clear live credential (token) + mode; **retain** origin (Grill Q2).
- No new HTTP endpoints. No CloudKit schema change.
- **Point to:** Sequence + OWASP below.

### Concept 1 — Dual transport gate

Code `normalize` (https-except-loopback) + Watch ATS loopback exceptions must agree so local `http://127.0.0.1:3000` works; remote cleartext still blocked.

### Concept 2 — Leave keeps host

Session end drops Bearer token; saved base URL stays for faster Cloud reconnect.

## Design patterns used

### 1. Phone-parity ATS exception domains

- **What it is:** Watch Info gets the same `NSAppTransportSecurity` → `NSExceptionDomains` loopback exceptions Phone already ships (`127.0.0.1`, `localhost`, insecure HTTP allowed).
- **How we use it here:** Edit `Config/WatchApp-Info.plist` only; keep existing `mybaby` URL scheme; leave shared normalize/Fail/Offline/coalescer as verify.
- **Why:** Watch currently has scheme only and no ATS block — local Cloud `http://127.0.0.1:3000` fails ATS while Phone works.
- **Best practices:** Exception domains for loopback only; pair with `BabyAPIConfig.normalize` so remote cleartext stays blocked.
- **Anti-pattern:** `NSAllowsArbitraryLoads` (or any global cleartext allow) — never ship that.
- **Reference:** `MyBaby Phone App/Info.plist`; [Apple ATS](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity)

### 2. Config normalize gate (reuse — verify)

- **What it is:** Shared `BabyAPIConfig.normalize` accepts `https` or loopback `http` only.
- **How we use it here:** Verify Watch paste / preset / redeem still hit this one path; do not fork Watch-only URL logic.
- **Why:** Code gate + ATS must agree (Concept 1); phone-security-perf already landed the Major.
- **Best practices:** One normalize for paste, preset, redeem; reject early before save.
- **Anti-pattern:** Trusting ATS alone, or a second Watch-only URL parser.
- **Reference:** `BabyCareShared/BabyAPIConfig.swift`; existing Watch AppTests normalize cases

### 3. Coalesced widget notify (reuse — verify)

- **What it is:** `WidgetTimelineReloadCoalescer` debounces WidgetKit reload after App Group persist.
- **How we use it here:** Confirm Watch care persist still saves DTO then schedules coalesced reload — no new helper.
- **Why:** Rapid wrist taps must not thrash complication timelines.
- **Best practices:** Save App Group DTO first; debounce/cancel pending reload Task; do not debounce the data write.
- **Anti-pattern:** Calling `reloadTimelines` on every persist without coalesce.
- **Reference:** `BabyCareShared/WidgetTimelineReloadCoalescer.swift`

### 4. User-safe Fail map (reuse — verify)

- **What it is:** `BabyLiveStatusFailCopy` maps live failures to caregiver-safe strings (no raw GraphQL / token-like text).
- **How we use it here:** Verify Watch Failed + Retry still uses this map; do not redo production scrub this pass (`"HTTP \(code)"` stays — Grill defer).
- **Why:** Analysis reusable pattern; Gate A keeps Fail + Retry visible without leaking secrets in error UI.
- **Best practices:** Known codes stay specific; unknown → generic; never assign raw `graphQL.message` to `statusFail`.
- **Anti-pattern:** Surfacing server error bodies or pairing payloads in status Fail copy.
- **Reference:** `BabyCareShared/BabyLiveStatusFailCopy.swift`; Sequence Fail path; Task 3 verify

### 5. App Group status mailbox (reuse — verify)

- **What it is:** `BabyCareStatusStore` writes a status-only DTO to the App Group; `forbiddenKeys` blocks token/secret keys.
- **How we use it here:** Verify Watch → widgets path still uses mailbox + deny-list; complications read status only.
- **Why:** Analysis reusable pattern; Outcome requires no secrets in App Group / widgets.
- **Best practices:** Status fields only; deny-list enforced on write; widgets never network or read Keychain.
- **Anti-pattern:** Putting Bearer token, pairing code, or base-URL credentials into App Group defaults.
- **Reference:** `BabyCareShared/BabyCareStatusStore.swift`; Task 3 `forbiddenKeys` verify

## Sequence

```text
Dev Cloud on Watch
  → paste/preset http://127.0.0.1:3000
  → normalize accepts loopback http
  → ATS exceptions allow insecure load
  → pair/redeem + Keychain token
  → live GraphQL / care

Leave (Settings)
  → clear Keychain token + disconnect mode
  → base URL retained
  → Connect shown (Offline default)
  → re-pair/token only to resume Cloud

Care persist → App Group DTO save → coalesced WidgetKit reload
Fail path → BabyLiveStatusFailCopy → Failed + Retry (no raw GQL)
```

## API contracts

**N/A** — Has API **no**. Still `POST …/api/graphql/baby` and `POST …/api/watch/pair/redeem`.

## Database contracts

**N/A** — Has DB **no**. Offline query already `resultsLimit 80` + `desiredKeys` in shared code (verify only).

### Example queries

**N/A** for this run (no query change). Existing Offline shape (reference only):

```text
CKQuery CareEvent · sort at DESC · resultsLimit 80
desiredKeys: kind, at, schemaVersion, side, ml, diaperKind, durationSec
```

## OWASP (mobile client)

| OWASP | Status | Note |
|-------|--------|------|
| A01 Broken Access | ok | Bearer Keychain; Leave clears token |
| A02 Crypto failures | target | ATS Phone-parity + https-except-loopback verify |
| A03 Injection | ok | No new query composition |
| A04 Insecure design | ok | Fail copy sanitized (verify); HTTP code text deferred |
| A05 Misconfig | target | Watch Info ATS aligned with Phone |
| A06 Vulnerable comps | n/a | |
| A07 Auth failures | ok | pairUserMessage already safe |
| A08 Integrity | ok | |
| A09 Logging | ok | Do not log tokens |
| A10 SSRF | soft | Client origin gate reduces odd http bases |

**Trust boundaries:** Keychain vs UserDefaults base URL vs App Group vs CloudKit vs network.  
**Abuse:** non-loopback http paste; GQL error with token-like text; App Group key pollution.

## Non-goals

- Re-implement shared phone-security-perf Majors
- `clearBaseURL` on Watch logout
- Keychain ThisDeviceOnly; pairing SecureField; HTTP Fail scrub
- Phone-only UI; server/GraphQL schema; Connect IA rewrite; pure visual polish

## Aggressive challenges

| Challenge | Response |
|-----------|----------|
| Leave without clearBaseURL is weaker than Phone | Human Grill Q2 — token clear is the live credential; host retained for reconnect UX |
| ATS exceptions widen cleartext | Loopback domains only; normalize still rejects remote http |
| Verify-only misses a shared regression | Task 3 re-runs existing Watch unit suite covering those Majors |
| Why not ship Enhancements now | Grill Q3 defer; not Watch-blocking for ATS + verify |

## Risks

- Shared suite must stay green — Watch build consumes same helpers.
- ATS plist typo could block local Cloud or over-open loads — mirror Phone keys exactly.
- Residual saved URL after Leave on shared device — accepted; token still required.

## Domain / ADR notes

Grill: **ADR skipped** — reversible plist/Leave policy. No glossary updates.

## Clarity check

Is this design clear? Which option do you approve? Any concerns before build?
