# Tasks: watch-security-perf

**Design option:** Option 1 (pending Gate B)  
**TDD:** mixed — one new Leave unit; ATS limited surface; shared Majors **verify-only** (no new tests)

## Task 1 — Watch ATS Phone-parity (S)

- **Acceptance:** `Config/WatchApp-Info.plist` has `NSAppTransportSecurity` → `NSExceptionDomains` for `127.0.0.1` and `localhost` with `NSExceptionAllowsInsecureHTTPLoads` = true (and `NSIncludesSubdomains` as on Phone). No `NSAllowsArbitraryLoads`. Existing `mybaby` URL scheme kept. UI locks unchanged (Connect Offline + care + Fail/Retry).
- **Tests (TDD):** **Limited unit surface** — do **not** invent ATS runtime unit tests. Prefer re-run / rely on existing `BabyAPIConfig.normalize` loopback vs non-loopback cases. Acceptance check: plist keys match `MyBaby Phone App/Info.plist` (source review in Build).
- **Files:** `Config/WatchApp-Info.plist` (template: `MyBaby Phone App/Info.plist`)

## Task 2 — Leave keeps saved base URL (S)

- **Acceptance:** `BabyHomeStatusModel.logout` still clears Keychain token + disconnects; **does not** call `BabyAPIConfig.clearBaseURL()`. Saved origin remains after Leave. Gate A Leave intent preserved (token gone → Connect).
- **Tests (TDD):** **New unit** — extend or add beside `logoutClearsTokenAndDisconnects`: save a known base URL → logout → expect token nil / disconnected **and** base URL still equal to saved value.
- **Files:** `BabyCareShared/BabyHomeStatusModel.swift` (behavior already matches Grill — change only if drift); `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift`

## Task 3 — Verify shared phone-security-perf Majors (S) — verify-only

- **Acceptance:** Confirm Watch consumes shared paths already in tree: https-except-loopback normalize; `BabyLiveStatusFailCopy` (no raw GQL); `OfflineCareFetchLimits.recentForStatus == 80` + desiredKeys; `WidgetTimelineReloadCoalescer` on persist; App Group `forbiddenKeys`. **Watch deep-link / `mybaby` scheme:** `onOpenURL` / `BabyHomeDeepLink` opens page or settings only — no query→token (or other secret) path; existing deep-link unit stays green. **Do not redo** production remediations unless a test fails.
- **Tests:** **No new tests planned** — run existing Watch AppTests that already cover normalize / Fail copy / Offline 80 / coalescer / App Group `forbiddenKeys` / deep-link page-settings gate.
- **Files:** none for green path (read-only verify)

## Task 4 — Smoke closeout (S)

- **Acceptance:** MyBaby Watch App (+ Watch Widgets if touched) **BUILD SUCCEEDED**; unit suite green including Task 2. Design UI locks hold (no IA change).
- **Tests:** Same unit target as Task 3; note build command in `06-test-log.md` later.
- **Files:** none beyond Tasks 1–2

## Out of scope

- Keychain ThisDeviceOnly; pairing SecureField; HTTP Fail scrub; `clearBaseURL` on Watch logout; Phone-only work; server schema.
