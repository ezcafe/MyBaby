# Analysis: phone-security-perf

**Size:** Prefer bullets. ≤5 solution pieces.

**Has API recommendation:** no — client hardening only; no new/changed public HTTP contracts  
**Has DB recommendation:** no — CloudKit query/limit tweak only; no new record fields/migrations (treat as client persistence hygiene, not SQL Has DB)

## Deep dive (required)

### Overall

#### What is this?
Audit MyBaby **Phone App** (+ shared Phone paths) for **security** and **performance**, then design/ship the highest-priority fixes without breaking Connect / quick care / widgets.

#### Why do we need this?
Care data and Bearer tokens sit on-device; Offline CloudKit and live GraphQL can stall or thrash. Skipping leaves unknown Critical/Major risk after M2/M3 landed on top of an older M1 “clean” security lens.

#### How to do this?
1. Evidence-based audit of token, URL, error UI, CloudKit fetch, widget reload.  
2. Fix Critical/Major with small shared helpers + tests.  
3. Defer Enhancements unless free.

- **Other ways:** Audit-only report (rejected — Decision 1 Option 1); full Connect rewrite (out of scope).
- **Best practices:** OWASP mobile (secrets, cleartext, error leakage); Apple Keychain + ATS; measure-ish caps on CloudKit `resultsLimit` / widget reload coalescing.

### Solution pieces

#### 1. Cloud URL / redeem baseURL scheme policy

##### What is this?
`BabyAPIConfig.normalize` allows `http` and `https` for any host. ATS blocks most cleartext hosts, but redeem/`saveBaseURL` can persist a non-loopback `http` origin or a surprising host from the server.

##### Why do we need this?
Stop cleartext or oddly trusted origins from becoming the saved live API base after pair/paste.

##### How to do this?
- Approach: Allow `http` only for loopback (`127.0.0.1` / `localhost`); require `https` otherwise; apply on normalize/save and on redeem `baseURL`.
- Other ways: Certificate pinning (heavier); leave ATS-only (weaker policy signal).
- Best practices: Apple ATS intent — cleartext only where explicitly excepted.

#### 2. GraphQL error message leakage

##### What is this?
`BabyHomeStatusModel.applyLiveFailure` sets `statusFail = message` for generic GraphQL errors (raw server text).

##### Why do we need this?
Avoid showing internal/server detail on care Fail UI (and screenshots).

##### How to do this?
- Approach: Map known codes; else generic “Could not update care — retry” (keep UNAUTHORIZED / network cases as today).
- Other ways: Log detail to `os.Logger` only (optional Enhancement).
- Best practices: OWASP — generic user errors; no secret/stack echo.

#### 3. Offline fetch size / keys

##### What is this?
`refreshOfflineSnapshot` uses `fetchRecent(limit: 500)` with CloudKit `desiredKeys: nil`.

##### Why do we need this?
Large Offline histories slow Connect/home refresh on MainActor-driven paths.

##### How to do this?
- Approach: Lower limit to what status mapping needs (e.g. 80–120); set `desiredKeys` to CareEvent fields only.
- Other ways: Local cache/index (bigger); paginate (more UI).
- Best practices: CloudKit — limit results; fetch only needed keys.

#### 4. Widget timeline reload thrash

##### What is this?
`persistStatusForWidgets` saves App Group DTO then `WidgetCenter.reloadTimelines` for **Watch + Phone** kinds on many care taps (including timer start).

##### Why do we need this?
Frequent full reloads burn CPU/battery and delay UI; Phone-only sessions still poke Watch kinds.

##### How to do this?
- Approach: Coalesce reloads (debounce ~0.5–1s) and/or reload only kinds that exist for the process; keep immediate save to App Group.
- Other ways: Reload only on scene background (stale widgets longer).
- Best practices: WidgetKit — reload when data changes, not on every transient tick if timeline policy already covers timers.

#### 5. Keychain accessibility (Enhancement)

##### What is this?
`BabyAPITokenStore` uses `kSecAttrAccessibleAfterFirstUnlock` (not ThisDeviceOnly).

##### Why do we need this?
Slightly stronger device-bound secret storage for backups/migration edge cases.

##### How to do this?
- Approach: Switch to `AfterFirstUnlockThisDeviceOnly` if Gate B includes Enhancement; migration = clear+re-save on next connect.
- Other ways: Leave as-is (already better than UserDefaults).
- Best practices: Apple Keychain accessibility tiers.

## Audit snapshot (evidence)

| Severity | Area | Evidence | Fix in this run? |
|----------|------|----------|------------------|
| Major | Security | Raw GQL `message` → `statusFail` | yes |
| Major | Security | `http` allowed for any host in normalize/save/redeem | yes |
| Major | Perf | Offline `limit: 500`, `desiredKeys: nil` | yes |
| Major | Perf | Widget reload every persist (both kinds) | yes |
| Enhancement | Security | Keychain accessibility not ThisDeviceOnly | Gate B optional |
| Enhancement | Security | Pairing code `TextField` (not SecureField) | defer |
| OK | Security | Keychain token; Leave clears; App Group forbid keys; ATS localhost-only | keep |

## Design tree (frontier)

1. **URL policy** — https-except-loopback vs ATS-only?
2. **Offline limit** — 80 vs 120 vs keep 500?
3. **Widget reload** — debounce vs process-filtered kinds vs both?
4. **GQL errors** — always generic vs keep selected codes?
5. **Keychain ThisDeviceOnly** — include now vs defer?

## Settled (from idea / Decision 1)

- Audit **then fix** in this run (Option 1).
- Watch-only work out of scope unless shared path.
- Preserve Connect Offline default, care #1/#2, Failed + Retry.

## Spike notes

None required beyond code read of shared Phone paths (primary sources in `01-idea` / skim).
