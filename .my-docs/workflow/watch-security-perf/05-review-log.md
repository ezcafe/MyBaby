# Review log: watch-security-perf

**SPM plan:** security+perf  
**Updated:** 2026-10-01

## Adversarial

**Result:** clean  
**Round:** 1

| Severity | Finding | Status |
|----------|---------|--------|
| — | Task 2 `logoutKeepsSavedBaseURL` — save origin → logout → token nil / disconnected / client nil **and** `loadBaseURL` still equals saved; AuthGate shows Connect | ok |
| — | Task 1 ATS — no invented ATS runtime unit (per 04 / 04a); Watch plist mirrors Phone exception domains; pair with existing `httpsExceptLoopbackRejectsCleartextRemote` + loopback accept | ok |
| — | Task 3 verify — existing units still map: normalize, `unknownGraphQLErrorHidesRawServerMessage`, Offline 80 + desiredKeys, coalescer, `forbiddenKeys`, deep-link page/settings | ok |
| — | No mock theater on Leave path — real `BabyHomeStatusModel.logout` + `InMemoryBabyAPITokenStore` + real `BabyAPIConfig` defaults | ok |
| Nit | `logoutKeepsSavedBaseURL` uses `.standard` (not suite) — correct to catch default `clearBaseURL()`; restore via `defer` | accepted |
| FYI | ATS “no `NSAllowsArbitraryLoads`” stays source-review only — intentional limited surface | — |
| FYI | No Watch UITest for Settings Leave → `logout()`; suite is model-level (smoke notes no Watch e2e harness) | — |

**Coverage vs 04-tasks**

| Task | Scenario | Covered? |
|------|----------|----------|
| 1 | Phone-parity ATS keys in `Config/WatchApp-Info.plist` | yes — Build/source; not unit |
| 1 | Normalize loopback ok / remote cleartext reject | yes — existing |
| 2 | Leave clears token + disconnect; keeps saved base URL | yes — `logoutKeepsSavedBaseURL` (~1031) |
| 2 | Gate A → Connect after Leave | yes — AuthGate assert |
| 3 | Fail scrub / Offline 80 / coalescer / forbiddenKeys / deep-link | yes — existing suite (smoke 166 pass) |

Zero Critical / Major / Enhancement. Adversarial test review: clean.

## Quality

**Result:** clean  
**Round:** 1  
**Reviewer:** Senior Verifier (did not author draft)

| Axis | Pass? | Note |
|------|-------|------|
| Correctness vs Option 1 / 04-tasks | yes | ATS Phone-parity in `Config/WatchApp-Info.plist`; `logout` clears token + disconnect, **no** `clearBaseURL`; `logoutKeepsSavedBaseURL` asserts origin kept + AuthGate Connect |
| Gate A #1 / #2 + Design UI locks | yes | No UI/IA edits this draft; care vertical pages + Fail/Retry toolbar + Connect Offline default + Settings Log out → `logout()` unchanged |
| Design patterns (best practices) | yes | Loopback `NSExceptionDomains` only; no `NSAllowsArbitraryLoads`; `mybaby` scheme kept; shared normalize / Fail / Offline 80 / coalescer / `forbiddenKeys` verify-only |
| Architecture / blast | yes | Watch Info + one unit; shared Leave behavior already matches Grill (no production model churn) |
| Readability | yes | Test name + comment match Leave-keeps-host intent; defer restore of prior base URL |
| Security (surface) | defer | Loopback ATS + token clear on Leave look correct; deep OWASP / Keychain / App Group → security lens |
| Performance (surface) | defer | No new hot-path code this draft; coalescer / Offline 80 verify-only → perf lens |

| Severity | Finding | Status |
|----------|---------|--------|
| — | none Critical / Major / Enhancement | — |
| Nit | `logoutKeepsSavedBaseURL` uses `.standard` (not suite) — intentional to catch default `clearBaseURL()`; `defer` restores | accepted (same as Adversarial) |
| FYI | SPM plan security+perf — deep findings deferred to those lenses | — |

**Verification story:** Smoke `06-test-log.md` — Watch AppTests **TEST SUCCEEDED** (166), includes `logoutKeepsSavedBaseURL`.

Zero Critical / Major / Enhancement. Quality review: clean.

## Merged SPM

**SPM plan:** security+perf  
**Result:** clean  
**Round:** 1  
**Updated:** 2026-10-01

| Lens | File | Result | Fix ask |
|------|------|--------|---------|
| Security | `05-lens-security.md` | clean | none |
| Performance | `05-lens-performance.md` | clean | none |

**Dedup / conflict:** none — no overlapping Critical/Major/Enhancement; Security deferred Grill Q3 items and Perf FYI double-refresh stay documented, not Fix.

| Severity | Source | Finding | Decision |
|----------|--------|---------|----------|
| — | security | ATS Phone-parity + Leave-keep-URL + shared Majors | pass |
| — | perf | Offline 80 / desiredKeys / coalescer still shipped; no Watch thrash from draft | pass |
| Deferred | security (Grill Q3) | ThisDeviceOnly / pairing SecureField / HTTP Fail scrub | defer — not this run |
| Nit | security | `normalize` allows `::1` http; ATS lists IPv4 + localhost only | accept (Phone-parity) |
| FYI | perf | Offline Start may refresh twice (AuthConnect + ContentView task) | out of Option 1 — do not Fix |

**Merged SPM:** clean  
**Overall review:** clean — Adversarial + Quality + SPM all clean; no Fix round.

## Fix ask

None.
