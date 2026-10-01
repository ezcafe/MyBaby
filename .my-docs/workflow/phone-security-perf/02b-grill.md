# Grill: phone-security-perf

**Result:** frontier-empty  
**HITL:** Gate B is blocking for Design approval; Grill auto-settled user-first (per my-plan-flow Grill prefer-auto)  
**Updated:** 2026-10-01

## Frontier rounds

### Round 1 — settled

❓ **Q1 — Cloud URL scheme policy**  
➡️ **Recommended: https except loopback** — caregivers on real hosts get TLS; local `http://127.0.0.1` / `localhost` still works for dev Cloud.

❓ **Q2 — Offline fetch limit**  
➡️ **Recommended: 80** — enough for last-care / overlays; cuts CloudKit payload vs 500.

❓ **Q3 — Widget reload**  
➡️ **Recommended: debounce ~0.75s + keep App Group save immediate** — widgets update soon; avoid reload storms on rapid taps.

❓ **Q4 — GraphQL Fail copy**  
➡️ **Recommended: generic user message** for unknown GQL errors; keep Unauthorized / network / missing-token strings.

❓ **Q5 — Keychain ThisDeviceOnly**  
➡️ **Recommended: defer Enhancement** — not required for Major bar; avoid surprise re-auth unless Gate B adds it.

## Scenario stress-test

| Scenario | Outcome (settled) |
|----------|-------------------|
| User pastes `http://example.com` + token | Reject save; show valid URL error; ATS never relied on alone |
| Redeem returns `https://evil.example` | Still trusted if pairing origin was that host — document; scheme check still requires https |
| Offline with 200+ CareEvents | Fetch 80 newest; status still derives last care |
| Rapid breast L/R toggles | App Group writes each time; WidgetCenter reloads coalesced |

## Glossary / ADR

- No new glossary terms required (existing: Offline, Cloud, CareEvent, App Group mailbox).
- No ADR — choices are hardening defaults, reversible with config/tests.

## Settled decisions (Design must honor)

1. https-except-loopback for normalize/save/redeem baseURL.
2. Offline `fetchRecent` limit **80**; set CareEvent `desiredKeys`.
3. Debounce widget timeline reloads (~0.75s); save DTO immediately.
4. Sanitize unknown GraphQL error messages in Fail UI.
5. Keychain accessibility change deferred unless Gate B expands scope.
