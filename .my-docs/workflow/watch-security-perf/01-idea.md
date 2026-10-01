# Idea: Watch App security + performance audit then fix

## Problem

Parents use the MyBaby Watch App for Offline (iCloud) or Cloud care logging at a glance. Security gaps (tokens, ATS/URL validation, CloudKit/App Group leakage, pairing, deep links) or performance stalls (main-thread work, status refresh thrash, complication timeline reloads) put baby data at risk or make 3am wrist taps feel broken. Phone already ran a security-perf pass; Watch + complications + shared Watch paths need their own Critical/Major pass — then ship fixes in this run.

## User / audience

Primary: caregivers on Apple Watch logging Feed / Sleep / Diaper / Pump (day and night). Secondary: same household sharing Offline via iCloud Apple ID; Cloud users pairing from web Settings. Developers maintaining Watch + widgets.

## Outcome

1. Ranked list of Watch-relevant security + performance findings (Critical/Major first).
2. Design + implement the highest-priority remediations that stay in Watch / shared Watch paths (and shared code only when Watch needs the fix).
3. Care Connect + quick-care + complications still work; Fail + Retry stay clear; no secrets in App Group / widgets / error UI.

## Metric

- Zero open Critical security issues in scope after fix; Major security/perf items either fixed or explicitly deferred with reason.
- Watch App (+ Watch Widgets if touched) builds; existing unit tests green; no new ATS/token regressions.

## Sources (primary)

| Claim / topic | Primary source (path, URL, or API) | Notes |
|---------------|--------------------------------------|-------|
| Watch surfaces + Connect Offline/Cloud | `README.md`; `MyBaby Watch App/*` | Vertical care pages + Settings |
| Token Keychain store | `BabyCareShared/BabyAPITokenStore.swift` | Not UserDefaults |
| Cloud URL / config | `BabyCareShared/BabyAPIConfig.swift`; `Config/WatchApp-Info.plist` | Pairing / URL schemes |
| Session leave clears token | `BabyCareShared/BabyHomeStatusModel.swift` | `logout` / leave |
| Care + App Group mailbox | `BabyCareShared/BabyCareStatusStore.swift`; `BabyCareShared/BabyHomeStatusModel.swift` | Status only; deny-list keys |
| CloudKit Offline | `BabyCareShared/CloudKitOfflineCareStore.swift`; `Config/WatchApp.entitlements` | Container `iCloud.vn.in4.MyBaby` |
| GraphQL Bearer calls | `BabyCareShared/BabyGraphQLClient.swift` | Live Cloud |
| Pairing redeem | `BabyCareShared/WatchPairClient.swift` | `POST …/api/watch/pair/redeem` |
| Complications / widgets | `MyBaby Watch Widgets/BabyCareWidgets.swift`; `BabyCareShared/BabyCareWidgetTimeline.swift` | App Group read; no network |
| Timeline reload coalesce | `BabyCareShared/WidgetTimelineReloadCoalescer.swift` | Perf path |
| Entitlements | `Config/WatchApp.entitlements`; `Config/Widgets.entitlements` | CloudKit + App Group |
| Prior memory pass | `.my-docs/workflow/watch-memory-optimize/` | Related, not authority |
| Phone security-perf (shared overlap) | `.my-docs/workflow/phone-security-perf/` | Shared fixes may already land; re-verify Watch |
| Apple ATS | https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity | Platform rules |
| Apple Keychain | https://developer.apple.com/documentation/security/keychain_services | Token storage |
| Apple WidgetKit / App Groups | https://developer.apple.com/documentation/widgetkit ; https://developer.apple.com/documentation/xcode/configuring-app-groups | Complications + shared defaults |
| watchOS performance | https://developer.apple.com/documentation/watchos-apps | Tight memory / main-thread budget |

## Has UI

**yes** — Connect, care pages, Settings leave, Fail/Retry, complication-facing status; fixes must not hide core care actions.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Prefer fixing shared models/stores over redesign. Keep Connect Offline default, vertical care pages, Failed + Retry. Any new security copy stays secondary (Settings / Advanced / Need help).

## 80/20 UI (day-to-day)

### Main user goals

- Connect once (Offline default or Cloud pair) and stay connected.
- Log Feed / Sleep / Diaper / Pump fast on wrist; see last care / timer.
- Leave / Log out when switching mode or device.
- Glance complications / Smart Stack without opening the app.

### Vital few (high-impact ~20%)

- Token never leaks to App Group / complications / logs / error UI.
- Offline CloudKit and Cloud GraphQL stay trustworthy and snappy enough for 3am wrist taps.
- Fail + Retry visible when care/status load fails.
- Leave clears live credentials so next session is intentional.

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Care page actions + current status / timer (or Failed + Retry).
- **Important info / action #2 (always visible):** Connect primary path (Start Offline / pair) when not connected.
- **Core action placement:** Vertical pages + primary Connect buttons unchanged in hierarchy.
- **Secondary actions:** Advanced paste URL & token; Settings leave; complication Care type config — keep less prominent.

### Top user journey to optimize

Cold start → Connect (Offline default or Cloud) → Care page log → (optional) complication glance → Leave when switching.

### Sensible defaults

- Offline selected by default on Connect.
- Cloud URL default local preset only for dev; production users change URL deliberately.
- Complication care type Auto when unset.

### Biggest usability risks to fix first

- Security hardening that forces extra steps on every care log.
- Perf “fixes” that blank status or remove Retry.
- Hiding Failed state or swallowing CloudKit/iCloud sign-in errors.

## Non-goals

- Phone-only UI redesign or Phone widget-only work (unless a shared buggy path requires a shared fix).
- New my-apps server features / GraphQL schema changes (prefer client-only).
- Full rewrite of Connect IA or new design system.
- Pure visual polish unrelated to security/perf.

## Assumptions to attack

- Phone security-perf shared fixes already cover Watch — verify Watch-specific paths (ATS plist, deep links, complications).
- Keychain + App Group deny-list is enough — verify no token in snapshots/logs/Fail copy.
- URL validation + ATS exceptions are the only insecure HTTP paths — verify Watch Info / config.
- Performance pain is client-side (main actor / refresh / CloudKit / timeline reload) not only network.
- Highest-priority fixes fit one Gate B scope without blocking day-to-day care.

## Success criteria

- [ ] Audit covers Connect, token store, GraphQL client, CloudKit Offline, App Group/complication mailbox, Watch care refresh / timeline paths.
- [ ] Critical findings fixed or run stopped with explicit escalate.
- [ ] Chosen Major fixes implemented + tests where Design plans them.
- [ ] Watch App build succeeds; targeted unit tests pass.
- [ ] Day-to-day Connect + care + Fail/Retry behavior preserved (Gate A #1/#2).

## Open questions

- Which Phone security-perf remediations already land in shared code and need only Watch verification vs new Watch-only work?
- Does Watch ship ATS exceptions in the same shape as Phone `Info.plist`, or only via other config?
- Any Watch-only Critical findings that should block Gate B scope expansion?
