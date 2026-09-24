# Test log: watch-api-base-url

## Smoke

**Result:** smoke-pass
**Updated:** 2026-09-24

| Check | Result | Notes |
|-------|--------|-------|
| Build | pass | `xcodebuild` Watch App + Widgets compiled |
| Unit | pass | `MyBaby Watch AppTests` on Apple Watch Series 10 (46mm) OS 11.5 — **TEST SUCCEEDED** (after inout fix) |

**Commands:**
```bash
xcodebuild -scheme "MyBaby Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm),OS=11.5' \
  -only-testing:"MyBaby Watch AppTests" test
```

## Lite test

**Result:** pass
**Updated:** 2026-09-24

Targeted unit suite (no new e2e in this run — Watch UITests not extended):

```bash
xcodebuild -scheme "MyBaby Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm),OS=11.5' \
  -only-testing:"MyBaby Watch AppTests/BabyHomeStatusTests" \
  -only-testing:"MyBaby Watch AppTests/BabyLiveModelTests" \
  -only-testing:"MyBaby Watch AppTests/BabyGraphQLRequestBuilderTests" \
  -only-testing:"MyBaby Watch AppTests/BabyAPIConfigTests" \
  test
```

**TEST SUCCEEDED** — includes live model + config + existing care model tests.
