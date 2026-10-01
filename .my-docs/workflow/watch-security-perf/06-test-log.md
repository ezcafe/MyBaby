# Test log: watch-security-perf

**Mode last run:** full

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-10-01

| Check | Result |
|-------|--------|
| Unit (`MyBaby Watch AppTests`) | **TEST SUCCEEDED** · 166 passed (re-verified; matches Build claim) |
| Watch App build | covered by `xcodebuild test` (scheme `MyBaby Watch App`) |
| Task 2 Leave URL | `logoutKeepsSavedBaseURL` passed |

Commands:
- `xcodebuild test -scheme "MyBaby Watch App" -destination 'platform=watchOS Simulator,id=AE5F3398-AAB0-4956-8316-926DE142CE77' -only-testing:"MyBaby Watch AppTests" -derivedDataPath ./build/DerivedDataWatch`

**Notes:** Fresh smoke re-run (not reuse-only). Destination: Apple Watch Series 10 (46mm) watchOS 11.5. No separate e2e harness for Watch. Watch Widgets not touched this draft — no extra Widgets build.

## Coverage

**Updated:** 2026-10-01

| Criterion / flow (04-tasks / design) | Coverage |
|--------------------------------------|----------|
| Task 1 ATS Phone-parity (plist) | Source/build verify — no ATS runtime unit planned |
| Task 2 Leave keeps saved base URL | Unit: `logoutKeepsSavedBaseURL` |
| Task 3 https-except-loopback normalize | Unit: existing `BabyAPIConfigTests` normalize cases |
| Task 3 Fail copy (no raw GQL) | Unit: `unknownGraphQLErrorHidesRawServerMessage` |
| Task 3 Offline limit 80 + desiredKeys | Unit: `PhoneSecurityPerfTests` (`offlineFetchLimitIsEighty`, desiredKeys) |
| Task 3 WidgetTimelineReloadCoalescer | Unit: coalescer + persist tests |
| Task 3 App Group forbiddenKeys | Unit: existing App Group forbid-list tests in Watch AppTests |
| Task 3 Deep-link page/settings only | Unit: existing deep-link tests |
| Task 4 Watch App build + suite green | Covered by full `xcodebuild test` below |

**Code coverage command:** none in repo (no README / script / scheme `enableCodeCoverage` workflow). Skipped — N/A.

**E2E gaps vs 04-tasks:** none required. Tasks plan **unit + build only**. No new e2e planned.

## Full test

**Result:** success  
**Updated:** 2026-10-01

| Check | Result |
|-------|--------|
| Unit (`MyBaby Watch AppTests`) | **TEST SUCCEEDED** · 166 passed · 0 failed · 0 skipped |
| Watch App build | covered by `xcodebuild test` (scheme `MyBaby Watch App`) |
| Task 2 Leave URL | `logoutKeepsSavedBaseURL` passed |
| E2E | **skipped** — 04-tasks do not require new e2e; `MyBaby Watch AppUITests` is template-only (not in task plan) |
| Code coverage report | **skipped** — no project coverage command |

Commands:
- `xcodebuild test -scheme "MyBaby Watch App" -destination 'platform=watchOS Simulator,id=AE5F3398-AAB0-4956-8316-926DE142CE77' -only-testing:"MyBaby Watch AppTests" -derivedDataPath ./build/DerivedDataWatch`

**Notes:** Fresh full re-run. Destination: Apple Watch Series 10 (46mm) watchOS 11.5. xcresult: `build/DerivedDataWatch/Logs/Test/Test-MyBaby Watch App-2026.10.01_8-58-46-+0700.xcresult`. Watch Widgets not touched — no extra Widgets build.

## Fix ask

None.
