# TDD test-case review: watch-security-perf

**Result:** ok  
**Round:** 1  
**Updated:** 2026-10-01  

## Planned / existing test cases reviewed

| Task | Scenario type (real / edge) | Test case | Covered? |
|------|-----------------------------|-----------|----------|
| 1 | real (limited surface) | Plist source review vs Phone ATS keys; no invented ATS runtime unit | yes |
| 1 | real / edge (verify) | Existing `BabyAPIConfig.normalize` loopback accept + remote cleartext reject | yes |
| 2 | real | New unit beside `logoutClearsTokenAndDisconnects`: save base URL → logout → token nil / disconnected **and** base URL retained | yes |
| 2 | edge | Assert does **not** clear origin (`loadBaseURL` still equals saved) — Grill keep-URL lock | yes |
| 3 | real (verify-only) | Existing normalize / Fail scrub / Offline 80 + desiredKeys / coalescer / `forbiddenKeys` | yes |
| 3 | real (verify-only) | Existing deep-link page + settings units stay green (page/settings only; no query→token path) | yes |
| 4 | real | Watch App BUILD + unit suite incl. Task 2 | yes |

## Gaps (must add before or during Build)

| Severity | Task | Missing scenario | Suggested test |
|----------|------|------------------|----------------|
| — | — | None | — |

## Real scenarios checked

- **Happy path:** Leave clears Keychain token + disconnect → Connect; saved host remains for reconnect.
- **User-visible failures:** Fail copy scrub already covered by existing Watch units (Task 3 verify).
- **Empty / loading / permission:** N/A for this delta (no new loading/permission UI).

## Edge scenarios checked

- **Boundaries / invalid input:** Normalize loopback vs non-loopback (existing); ATS limited to plist mirror (Task 1).
- **Concurrency / double-submit / idempotency:** Coalescer burst already covered (Task 3 verify).
- **Offline / partial data / race:** Offline 80 + desiredKeys existing (Task 3 verify).

## Fix ask for Build

None.

## Round notes

- Prereq `03a` Result **clean** (round 2). Did not edit `01`–`04`. No production code.
- Task 1 correctly forbids inventing ATS runtime units; Build acceptance = plist key mirror of Phone Info.
- Task 2 is the only new red-first unit; prefer isolated `UserDefaults(suiteName:)` when saving/asserting base URL so the suite does not pollute `.standard`.
- Task 3 verify-only is adequate: `MyBaby_Watch_AppTests` already covers normalize, Fail copy, Offline 80, coalescer, `forbiddenKeys`, and deep-link page/settings.
- Ready for **Gate B** (blocking — security in scope).
