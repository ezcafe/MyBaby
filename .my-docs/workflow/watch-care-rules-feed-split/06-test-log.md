# Test log: watch-care-rules-feed-split

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-09-23  
**Command:** `xcodebuild -scheme "MyBaby Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 12 (46mm)' -only-testing:"MyBaby Watch AppTests" test`

| Check | Result |
|-------|--------|
| Build | pass |
| Unit | pass (25 cases) |

Notes: main-thread Build + Smoke — Task usage limit.

## Full test

**Result:** success  
**Updated:** 2026-09-23  

Same unit suite as smoke (Watch has no separate e2e harness in-repo). Coverage/add-e2e Tasks: n/a for this local Watch UI pass (04-tasks did not require new XCUITest).

| Suite | Result |
|-------|--------|
| MyBaby Watch AppTests | all passed |
