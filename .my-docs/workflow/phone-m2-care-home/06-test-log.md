# Test log: phone-m2-care-home

## Smoke

| Check | Result | Evidence |
|-------|--------|----------|
| Phone App build | **pass** | CLI `xcodebuild -scheme "MyBaby Phone App" -destination 'generic/platform=iOS Simulator' build` → **BUILD SUCCEEDED** |
| Watch App unit tests | **pass** | CLI `xcodebuild test -scheme "MyBaby Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm),OS=11.2' -only-testing:"MyBaby Watch AppTests"` → **TEST SUCCEEDED** · 148 passed · 0 failed |
| `PhoneCareWiringTests` | **pass** | `applyOffline…`, `applyLive…`, `refreshLive…`, `refreshOffline…` all passed |

**Smoke status:** **pass**

## Full / lite

| Check | Result | Notes |
|-------|--------|-------|
| Unit suite | **pass** | Full `MyBaby Watch AppTests` green via CLI |
| E2E | **skipped** | No Phone UITest target for M2; watch UITests not required for this milestone |

**Full status:** **pass** (unit + build; native e2e N/A)

## Round notes

- **20:40** · smoke-partial · Phone build pass from DerivedData; tests canceled
- **20:44** · pass · CLI build + test with `required_permissions: all` (sandbox blocks macros/simulator)
