# Grill: watch-security-perf

**Result:** frontier-empty  
**HITL:** Gate B **blocking** — human settled Round 1 (`1 / 2 / 1`).  
**Updated:** 2026-10-01  
**Code cross-check:** confirmed against tree (facts below).

## Facts settled (look-up — not for human)

| Claim | Code evidence | Status |
|-------|---------------|--------|
| Watch ATS gap | `Config/WatchApp-Info.plist` — URL scheme only; **no** `NSAppTransportSecurity` | confirmed |
| Phone ATS template | `MyBaby Phone App/Info.plist` — exceptions for `127.0.0.1` + `localhost` insecure loads | confirmed |
| Shared URL policy | `BabyAPIConfig.normalize` — `http` only loopback; else `https` | confirmed (verify, not redo) |
| Watch Leave gap | `BabyHomeStatusModel.logout` clears Keychain + mode; **no** `clearBaseURL()` | confirmed |
| Phone Leave parity | `PhoneSessionModel.leave` calls `BabyAPIConfig.clearBaseURL()` | confirmed |
| Watch Leave UI | `CarePages` Settings → `model.logout()` | confirmed |
| Keychain tier | `BabyAPITokenStore` — `kSecAttrAccessibleAfterFirstUnlock` (not ThisDeviceOnly) | confirmed |
| Fail HTTP text | `BabyLiveStatusFailCopy` — `.httpStatus(code)` → `"HTTP \(code)"` | confirmed |
| Pairing field | `AuthConnectView` — pairing code `TextField`; Advanced token already `SecureField` | confirmed |
| Deep link / mailbox | `BabyHomeDeepLink` page/settings only; App Group `forbiddenKeys`; coalescer on persist | confirmed OK |

## Round 1 — settled (human `1 / 2 / 1`)

❓ **Q1 — Watch ATS** → **Chosen: Option 1** (Phone-parity loopback exceptions)  
Recommended was Option 1 — matched.

❓ **Q2 — Leave / logout base URL** → **Chosen: Option 2** (keep saved origin after Leave)  
Recommended was Option 1 — human overrode for faster Cloud reconnect; token still cleared.

❓ **Q3 — Enhancement scope** → **Chosen: Option 1** (defer ThisDeviceOnly / pairing SecureField / HTTP Fail scrub)  
Recommended was Option 1 — matched.

## Scenario stress-test

| Scenario | Expected outcome (if recommended picks) |
|----------|----------------------------------------|
| Dev Cloud: Watch Connect to `http://127.0.0.1:3000` after ATS Option 1 | ATS allows loopback cleartext; normalize still rejects non-loopback `http` |
| Caregiver Leaves Cloud on Watch, then reconnects | Token gone; **base URL kept** (human Q2 Option 2); re-pair/token only |
| Rapid care taps with Fail on GQL | Fail stays sanitized via `BabyLiveStatusFailCopy`; `"HTTP \(code)"` remains until Enhancement (deferred) |
| Complication open with leftover App Group | Status DTO only; no token keys (forbid-list) |

## Glossary / ADR

- **Glossary:** none — no `GLOSSARY.md` / `GLOSSARY-MAP.md` in repo; no new domain terms beyond existing Offline / Cloud / Leave / App Group mailbox.
- **ADR skipped** — ATS Phone-parity + Leave clearBaseURL + Enhancement defer are reversible plist/model choices aligned with phone run; fail three-part bar (not hard-to-reverse architecture).

## Chosen picks (human)

1. **Q1 ATS** → Option 1 Phone-parity loopback exceptions  
2. **Q2 Leave** → Option 2 keep saved origin (do **not** call `clearBaseURL` on Watch logout)  
3. **Q3 Enhancements** → Option 1 defer ThisDeviceOnly / pairing SecureField / HTTP Fail scrub  

## Design must honor

Verify shared Majors + add Watch ATS Phone-parity plist only. **Do not** clear base URL on Leave. Defer Enhancements as non-goals.

## Grill digest

1. Human settled `1 / 2 / 1` — frontier empty.  
2. Ship: Watch ATS Phone-parity + verify shared security/perf.  
3. Leave keeps base URL; token still cleared.  
4. No glossary/ADR.
