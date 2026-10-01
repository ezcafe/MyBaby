# Idea: Phone App security + performance audit then fix

## Problem

Parents use the MyBaby Phone App for Offline (iCloud) or Cloud care logging. Security gaps (tokens, ATS, CloudKit/App Group leakage, pairing) or performance stalls (main-thread work, refresh thrash, widget timelines) put baby data at risk or make quick care at 3am feel broken. Prior M1 security lens was clean for shell/Connect, but M2 care home + M3 widgets and shared paths need a fresh Critical/Major pass — then ship fixes in this run.

## User / audience

Primary: caregivers on iPhone logging Feed / Sleep / Diaper / Pump (day and night). Secondary: same household sharing Offline via iCloud Apple ID; Cloud users pairing from web Settings.

## Outcome

1. Ranked list of Phone-relevant security + performance findings (Critical/Major first).
2. Design + implement the highest-priority remediations that stay in Phone / shared Phone paths.
3. Care Connect + quick-care + widgets still work; Fail + Retry stay clear; no secrets in App Group / widgets.

## Metric

- Zero open Critical security issues in scope after fix; Major security/perf items either fixed or explicitly deferred with reason.
- Phone App (+ widget extension if touched) builds; existing unit tests green; no new ATS/token regressions.

## Sources (primary)

| Claim / topic | Primary source (path, URL, or API) | Notes |
|---------------|--------------------------------------|-------|
| Phone surfaces + Connect Offline/Cloud | `README.md`; `MyBaby Phone App/*` | M1–M3 product shape |
| Token Keychain store | `BabyCareShared/BabyAPITokenStore.swift` | Not UserDefaults |
| Cloud URL / ATS localhost | `BabyCareShared/BabyAPIConfig.swift`; `MyBaby Phone App/Info.plist` | http://127.0.0.1 + localhost exceptions only |
| Session leave clears token | `BabyCareShared/PhoneSessionModel.swift` | Leave / Log out |
| Care + App Group mailbox | `BabyCareShared/BabyHomeStatusModel.swift`; `BabyCareShared/BabyCareStatusStore.swift` | Status only; deny-list tokens |
| CloudKit Offline | `BabyCareShared/CloudKitOfflineCareStore.swift`; `Config/PhoneApp.entitlements` | Container `iCloud.vn.in4.MyBaby` |
| GraphQL Bearer calls | `BabyCareShared/BabyGraphQLClient.swift` | Live Cloud |
| Prior M1 security notes | `.my-docs/workflow/phone-m1-shell-connect/05-lens-security.md` | Baseline, not authority |
| Apple ATS | https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity | Primary platform rules |
| Apple Keychain | https://developer.apple.com/documentation/security/keychain_services | Token storage guidance |
| Apple WidgetKit / App Groups | https://developer.apple.com/documentation/widgetkit ; https://developer.apple.com/documentation/xcode/configuring-app-groups | Widget + shared defaults |

## Has UI

**yes** — Connect, care tabs, Settings leave, Fail/Retry, widget-facing status; fixes must not hide core care actions.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Prefer fixing shared models/stores over redesign. Keep Connect Offline default, care tabs hierarchy, Failed + Retry. Any new security copy stays secondary (Settings / Advanced).

## 80/20 UI (day-to-day)

### Main user goals

- Connect once (Offline default or Cloud pair) and stay connected.
- Log Feed / Sleep / Diaper / Pump fast; see last care / timer.
- Leave / Log out when switching mode or device.
- Glance Home Screen widget without opening the app.

### Vital few (high-impact ~20%)

- Token never leaks to App Group / widget / logs / error UI.
- Offline CloudKit and Cloud GraphQL stay trustworthy and snappy enough for 3am taps.
- Fail + Retry visible when care/status load fails.
- Leave clears live credentials so next session is intentional.

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Care tab actions + current status / timer (or Failed + Retry).
- **Important info / action #2 (always visible):** Connect primary path (Start Offline / pair) when not connected.
- **Core action placement:** Bottom tabs + primary Connect buttons unchanged in hierarchy.
- **Secondary actions:** Advanced paste URL & token; Settings leave; widget config — keep less prominent.

### Top user journey to optimize

Cold start → Connect (Offline default or Cloud) → Care home log → (optional) widget glance → Leave when done switching.

### Sensible defaults

- Offline selected by default on Connect.
- Cloud URL default local preset only for dev; production users change URL deliberately.
- Widget care type Auto when unset.

### Biggest usability risks to fix first

- Security hardening that forces extra steps on every care log.
- Perf “fixes” that blank status or remove Retry.
- Hiding Failed state or swallowing CloudKit/iCloud sign-in errors.

## Non-goals

- Watch-only UI redesign or Watch complications-only work (unless shared buggy path).
- New my-apps server features / GraphQL schema changes (unless a Phone client bug forces a tiny contract note — prefer client-only).
- Full rewrite of Connect IA or new design system.
- Shipping Watch App binary changes as the primary deliverable.

## Assumptions to attack

- M1 security lens “clean” still holds after M2/M3 — may be false.
- Keychain + App Group deny-list is enough — verify no token in snapshots/logs.
- ATS localhost exceptions are the only insecure HTTP path — verify URL validation.
- Performance pain is client-side (main actor / refresh / CloudKit) not only network.
- Highest-priority fixes fit one Gate B scope without blocking day-to-day care.

## Success criteria

- [ ] Audit covers Connect, token store, GraphQL client, CloudKit Offline, App Group/widget mailbox, Phone care refresh paths.
- [ ] Critical findings fixed or run stopped with explicit escalate.
- [ ] Chosen Major fixes implemented + tests where Design plans them.
- [ ] Phone App build succeeds; targeted unit tests pass.
- [ ] Day-to-day Connect + care + Fail/Retry behavior preserved (Gate A #1/#2).

## Open questions

- Prefer shipping only Critical+selected Major in this run vs. all Major? (Gate B will pick.)
- Any production Cloud base URL (non-localhost) already in use that must stay HTTPS-only?
- Should widget timeline/perf be in scope if no security issue there? (Default yes for Major perf.)
