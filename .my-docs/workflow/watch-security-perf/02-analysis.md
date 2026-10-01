# Analysis: watch-security-perf

**Size:** Prefer bullets. ≤5 solution pieces. Spike ≤5 rows. Stay within artifact size caps.

**Has API recommendation:** no — client harden / Watch plist only; reuse pair redeem + GraphQL  
**Has DB recommendation:** no — no CloudKit schema/migration; Offline query already capped in shared code  
**Grill recommended?** yes — settled by human `1 / 2 / 1` (frontier-empty)

## Deep dive (required)

### Overall

#### What is this?
Security + performance **audit then fix** for **MyBaby Watch App** (+ Watch Widgets + shared Watch paths). Parallel to `phone-security-perf`; focus on Watch-only gaps after shared remediations already landed in `BabyCareShared`.

#### Why do we need this?
Wrist care holds Bearer tokens and baby status. Skipping Watch ATS / deep links / complications while assuming Phone shared fixes leaves cleartext or residual config risk and unknown Critical/Major holes. Perf stalls on Offline refresh or WidgetKit thrash break 3am taps.

#### How to do this?
1. Evidence audit: compare Watch paths vs shared phone fixes already in tree.  
2. Rank Critical/Major; ship Watch-specific remediations (+ shared only if Watch still needs a gap).  
3. Keep Gate A 80/20: care actions + Fail/Retry + Connect Offline dominant; no IA rewrite.

- **Other ways:** Audit-only report (rejected — Outcome #2 is ship fixes); full Connect redesign (non-goal).
- **Best practices:** Reuse phone-security-perf patterns (`BabyAPIConfig` gate, `BabyLiveStatusFailCopy`, Offline limit 80, `WidgetTimelineReloadCoalescer`); Apple ATS + Keychain + App Groups; OWASP mobile — secrets out of widgets/errors.

##### Decision 1 — Run shape

###### Option 1 — Verify shared + fix Watch-only gaps (recommended)
- **What:** Treat shared URL / Fail / Offline / coalescer as **done**; Design remediates Watch ATS, Leave baseURL parity, complication/deep-link verify, optional Enhancements.
- **Example:** Add Phone-shaped ATS exceptions to `Config/WatchApp-Info.plist`; `logout` clears base URL like Phone `leave`.
- **Pros:** No double-work; hits skim Watch-specific risks; small blast.
- **Cons:** Relies on shared code staying correct (re-run unit suite).

###### Option 2 — Re-implement all phone remediations on Watch surfaces
- **What:** Re-touch shared helpers again “for Watch.”
- **Pros:** Forces re-read.
- **Cons:** Duplicate; already green in phone-security-perf tests.

**Recommendation:** Option 1.

### Solution pieces

#### 1. Shared phone-security-perf — verify (already in tree)

##### What is this?
Shared fixes from phone run: https-except-loopback `normalize`; `BabyLiveStatusFailCopy`; `OfflineCareFetchLimits.recentForStatus == 80` + `desiredKeys`; `WidgetTimelineReloadCoalescer` on `persistStatusForWidgets`.

##### Why do we need this?
Avoid re-fixing closed Majors; confirm Watch App / Widgets consume the same paths.

##### How to do this?
- Approach: Code+test confirm (Spike below); Watch build + existing unit suite in Design/tasks; no rewrite unless gap found.
- Other ways: Blind re-patch (waste).
- Best practices: One normalize path; debounce notify not App Group write.

#### 2. Watch ATS / cleartext loopback (Watch-only Major)

##### What is this?
`Config/WatchApp-Info.plist` has **no** `NSAppTransportSecurity` block (only `mybaby` URL scheme). Phone `Info.plist` excepts `127.0.0.1` / `localhost` insecure loads. Shared config still defaults Cloud to `http://127.0.0.1:3000`.

##### Why do we need this?
Without Watch ATS exceptions, local Cloud preset / redeem to loopback http can fail under default ATS while Phone works — or developers widen ATS poorly later.

##### How to do this?

###### Decision 2 — ATS on Watch

###### Option 1 — Phone-parity exception domains only (recommended)
- **What:** Copy Phone’s localhost / `127.0.0.1` `NSExceptionAllowsInsecureHTTPLoads` into Watch Info. No arbitrary loads.
- **Example:** Same keys as `MyBaby Phone App/Info.plist` → `Config/WatchApp-Info.plist`.
- **Pros:** Matches skim hard constraint + local preset; keeps https-except-loopback code policy.
- **Cons:** Cleartext still possible on loopback (intentional for dev).

###### Option 2 — No ATS exceptions; Cloud on Watch https-only
- **What:** Force production/https URLs; drop loopback http on Watch.
- **Pros:** Stricter transport.
- **Cons:** Breaks documented local preset / Connect guide; fights shared defaults.

**Recommendation:** Option 1.

#### 3. Deep links + complications mailbox

##### What is this?
`mybaby://home?page=…` via `ContentView.onOpenURL` → `BabyHomeDeepLink` (page / settings only). Complications read `BabyCareStatusStore` App Group DTO (status sentences/timers); no network; forbid-list keys in tests.

##### Why do we need this?
Skim risk: skip deep link / complication while assuming Phone shared fixes. Token must never enter App Group or Fail/widget copy.

##### How to do this?
- Approach: Verify scheme/host gate; no query→token path; keep DTO status-only; keep coalescer. Optional: ignore unknown schemes loudly in tests only.
- Other ways: Remove custom URL scheme (breaks complication deep link).
- Best practices: App Group = mailbox only; widgets offline; WidgetKit reload coalesced.

#### 4. Leave / logout credential hygiene (Watch gap vs Phone)

##### What is this?
`BabyHomeStatusModel.logout` clears Keychain token + mode, but **does not** `BabyAPIConfig.clearBaseURL()`. Phone `PhoneSessionModel.leave` clears both.

##### Why do we need this?
Residual saved origin after Leave is weaker than Phone; cold restore still needs token (safe), but Leave should be intentional for host too.

##### How to do this?
- Approach: Align Watch Leave with Phone — clear base URL on logout; keep Fail/Retry and Connect Offline default.
- Other ways: Keep URL for faster reconnect (UX convenience; weaker Leave).
- Best practices: Session end clears live credentials (token + origin).

#### 5. Residual Enhancements (Gate B optional)

##### What is this?
Keychain still `kSecAttrAccessibleAfterFirstUnlock` (not ThisDeviceOnly). Fail copy may show `HTTP \(code)`. Pairing code still `TextField`. Reload still both Watch+Phone kinds (already debounced).

##### Why do we need this?
Hardening completeness; not Watch-blocking if ATS + Leave + verify ship.

##### How to do this?
- Approach: Defer unless Gate B expands; document in Design non-goals.
- Other ways: Bundle Keychain ThisDeviceOnly now (migration = re-connect).
- Best practices: Apple Keychain tiers; phone run already deferred These.

## Audit snapshot (evidence)

| Severity | Area | Evidence | Fix in this run? |
|----------|------|----------|------------------|
| Major | Security (Watch) | Watch Info **no** ATS; Phone has localhost exceptions | **yes** (Decision 2) |
| Major | Security (parity) | Watch `logout` skips `clearBaseURL`; Phone `leave` clears | **yes** (recommend) |
| OK (verify) | Security | Shared https-except-loopback in `BabyAPIConfig` | keep / test |
| OK (verify) | Security | `BabyLiveStatusFailCopy` — no raw GQL message | keep / test |
| OK (verify) | Perf | Offline limit 80 + `desiredKeys` | keep / test |
| OK (verify) | Perf | `WidgetTimelineReloadCoalescer` (~750ms) on model | keep / test |
| OK | Security | Deep link page/settings only; App Group forbid keys; widgets App Group read | keep |
| OK | Security | Token Keychain; production `bypassAuth: false` | keep |
| Enhancement | Security | Keychain not ThisDeviceOnly; SecureField; HTTP code text | Gate B optional |

## What exists today

Watch App Connect + vertical care + Settings Leave share `BabyCareShared` with Phone. Phone-security-perf Majors already live in shared code; Watch Info ATS and Leave baseURL are the main Watch-only deltas. Complications use App Group status DTO + coalesced WidgetKit reload.

## Dependencies

- Shared helpers must stay green (`MyBaby Watch AppTests`).
- Local Cloud preset depends on ATS Option 1 + https-except-loopback.
- Gate A: do not hide care #1/#2, Fail+Retry, or Offline default.

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `Config/WatchApp-Info.plist` | ATS gap; `mybaby` scheme |
| `MyBaby Phone App/Info.plist` | ATS parity template |
| `BabyCareShared/BabyAPIConfig.swift` | https-except-loopback |
| `BabyCareShared/BabyLiveStatusFailCopy.swift` | Fail sanitization |
| `BabyCareShared/BabyHomeStatusModel.swift` | logout, persist, deep link, Offline refresh |
| `BabyCareShared/WidgetTimelineReloadCoalescer.swift` | reload debounce |
| `BabyCareShared/BabyCareStatusStore.swift` | App Group DTO + forbidden keys |
| `BabyCareShared/BabyHomePage.swift` | `BabyHomeDeepLink` |
| `MyBaby Watch App/ContentView.swift` | `onOpenURL` |
| `MyBaby Watch Widgets/BabyCareWidgets.swift` | complication read path |
| `.my-docs/workflow/phone-security-perf/` | prior shared remediations |

## Reusable patterns (prefer in Design)

| Pattern / name | Where it lives | Why Design should reuse it |
|----------------|----------------|----------------------------|
| Config normalize gate | `BabyAPIConfig.normalize` | One URL policy for paste/redeem/save |
| User-safe Fail map | `BabyLiveStatusFailCopy` | No raw server text on wrist |
| Coalesced widget notify | `WidgetTimelineReloadCoalescer` | Debounce reload; save DTO first |
| App Group status mailbox | `BabyCareStatusStore` | Never tokens in complications |
| Phone ATS exception domains | Phone `Info.plist` | Copy shape into Watch Info |

## System shape candidates (prefer in Design)

| Shape / concept | Where it lives | Why Design should teach it |
|-----------------|----------------|----------------------------|
| Shared client harden + Watch plist | `BabyCareShared` + `WatchApp-Info` | Runtime trust: Keychain / App Group / ATS / network |
| Complication offline mailbox | App Group → WidgetKit | No widget network; coalesce notify |
| Leave clears live credentials | model logout vs Phone leave | Session end boundary |

## Constraints and risks

- Skim hard constraints: token never App Group/Fail/widgets; Watch ATS verify; CloudKit private + mailbox only; client-only API reuse; Keep Connect Offline + vertical care + Failed/Retry.
- Do not break `http://127.0.0.1` local Cloud preset when adding ATS.
- Do not blank Fail+Retry or thrash WidgetKit on MainActor.
- Memory-only work lives in `watch-memory-optimize` — not this run’s primary fix list.

## Settled decisions (do not relitigate)

- Gate A ok — care actions + Fail/Retry + Connect Offline; no conflicting IA.
- Audit **then fix** in this run (not audit-only).
- Phone shared Majors already in tree — verify, do not redo blindly (Decision 1 Option 1).
- Has UI yes; prefer model/store/plist fixes over redesign.
- Non-goals: Phone-only UI; new server/GraphQL schema; Connect IA rewrite; pure visual polish.
- **Grill human:** ATS Phone-parity loopback exceptions; **keep** base URL on Leave (do not clearBaseURL); defer Keychain/SecureField/HTTP Fail scrub.

## Design tree (frontier)

### Settled
- Decision 1 → Option 1 (verify shared + Watch-only fixes)
- Has API **no** · Has DB **no**
- Gate A 80/20 locked
- ATS → Phone-parity exceptions in `WatchApp-Info.plist`
- Leave → keep saved origin (human overrode clearBaseURL recommendation)
- Enhancements → defer
- Code facts: Watch Info **no** ATS today; `logout` skips `clearBaseURL` (and stays that way); Keychain AfterFirstUnlock; Fail may show `HTTP \(code)`; pairing code is `TextField`

### Open frontier
*(empty)*

### Blocked
*(none)*

## Spike notes (optional)

| Spike | What / Why / How | Finding | Keep or discard |
|-------|------------------|---------|-----------------|
| URL validation | Read `BabyAPIConfig` | `http` only loopback; remote needs `https`; tests cover reject | Keep — already fixed |
| Watch ATS | Read `WatchApp-Info.plist` vs Phone Info | Watch: scheme only, **no** ATS; Phone: localhost exceptions | Keep — Watch Major |
| App Group DTO | Read `BabyCareStatusStore` | Status fields only; `forbiddenKeys` deny-list | Keep — OK |
| Coalescer from Watch model | Read `persistStatusForWidgets` | Save then `widgetReloadCoalescer.schedule()` (~750ms) | Keep — already fixed |
| Deep link | Read `BabyHomeDeepLink` + `onOpenURL` | page/settings only; no token query | Keep — OK |

## Blocking questions

None — Grill frontier-empty. Chosen: ATS Option 1, Leave Option 2 (keep URL), Enhancements Option 1 (defer).

## Clarity check

**Are instructions and reference files clear enough to design?**  
**Yes.** Ship Watch ATS Phone-parity + verify shared Majors; do not clear base URL on Leave; defer Enhancements.
