# Security lens: watch-security-perf

**Result:** clean  
**Stage:** spm-security  
**Updated:** 2026-10-01  
**Reviewer:** Security lens (did not author draft)  
**Sources:** OWASP Top 10 · `security-and-hardening` · Grill Settled `1 / 2 / 1`

**Grill honor:** ATS Phone-parity · Leave **keep** base URL · defer Enhancements (ThisDeviceOnly / pairing SecureField / HTTP Fail scrub) — do not fail Major for deferred items unless Critical.

## Scope reviewed

| Surface | Path | Check |
|---------|------|-------|
| Watch ATS | `Config/WatchApp-Info.plist` | Loopback exceptions vs Phone Info |
| Leave | `BabyHomeStatusModel.logout` + `logoutKeepsSavedBaseURL` | Token clear; origin retained |
| URL gate | `BabyAPIConfig.normalize` | https-except-loopback |
| Fail copy | `BabyLiveStatusFailCopy` | No raw GQL / token echo |
| App Group | `BabyCareStatusStore` | Status DTO + `forbiddenKeys` |
| Connect | `AuthConnectView` | Normalize on save; safe pair messages |
| Deep link | `BabyHomeDeepLink` / `onOpenURL` | Page/settings only |

## OWASP Top 10

| ID | Name | Status | Note |
|----|------|--------|------|
| **A01** | Broken Access Control | pass | Live Bearer from Keychain; Leave clears token + disconnects; deep link opens page/settings only — no query→token path |
| **A02** | Cryptographic Failures | pass | ATS Phone-parity loopback only + `normalize` rejects remote `http`; token in Keychain. ThisDeviceOnly deferred (Grill Q3) — not Critical |
| **A03** | Injection | pass | No new query/shell composition; Fail UI uses mapped strings, not raw server bodies |
| **A04** | Insecure Design | pass | Dual gate (normalize + ATS) matches Design; abuse cases covered. Deferred Enhancements honored — not reopened |
| **A05** | Security Misconfiguration | pass | `NSExceptionDomains` for `127.0.0.1` + `localhost` only; **no** `NSAllowsArbitraryLoads`; `mybaby` scheme kept |
| **A06** | Vulnerable Components | N/A | No new third-party deps this draft |
| **A07** | Auth Failures | pass | Logout clears Keychain token (unit-locked); `watchPairUserMessage` / Fail copy do not echo secrets. Pairing `TextField` deferred Enhancement |
| **A08** | Software / Data Integrity | pass | App Group mailbox is status Codable DTO; widgets read-only; no unsigned webhook change |
| **A09** | Logging / Monitoring Failures | pass | No Authorization / token logging observed on touched paths |
| **A10** | SSRF | pass (soft) | Client origin gate + loopback ATS; caregiver-chosen https host is expected self-host risk (same as prior Watch runs) |

## Draft checks (Tasks 1–3)

| Check | Result |
|-------|--------|
| Watch ATS mirrors Phone exception domains | yes — keys/`NSExceptionAllowsInsecureHTTPLoads`/`NSIncludesSubdomains` match `MyBaby Phone App/Info.plist` |
| No global cleartext allow | yes |
| Leave keeps saved base URL (Grill Q2) | yes — `logout` does not call `clearBaseURL`; test asserts origin retained |
| Leave still clears live credential | yes — Keychain clear + disconnect |
| Shared URL / Fail / App Group Majors | verify-only green — no production redo needed |
| Deep link secret injection | none — `page` query only |

## Findings

| Severity | Finding | Suggestion |
|----------|---------|------------|
| — | None Critical / Major | — |
| Deferred (Grill Q3) | Keychain `AfterFirstUnlock` (not ThisDeviceOnly); pairing code `TextField`; `"HTTP \(code)"` Fail text | Follow-up pass only — do not block this run |
| Nit | `normalize` allows `::1` http; ATS exceptions list IPv4 + `localhost` only (Phone-parity) | Accept unless a later pass adds `::1` exception |

## Fix ask

(none)

## Verdict

**clean** — Watch ATS Phone-parity + Leave-keep-URL match Grill; shared security Majors hold; deferred Enhancements are not Majors for this pass.
