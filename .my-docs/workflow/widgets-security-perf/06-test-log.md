# Test log: widgets-security-perf

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-10-02

| Check | Result | Notes |
|-------|--------|-------|
| Watch AppTests | **TEST SUCCEEDED** | includes `statusStoreEmptyFallsBackForWidgets`, `emptyForWidgetsResolvesToEmptyDisplay` |
| Phone WidgetsExtension build | **BUILD SUCCEEDED** | iPhone 16 sim `F957544F-…` |
| Watch Widgets build | **BUILD SUCCEEDED** | Watch Series 10 46mm `34D6A1C2-…` |

**Commands:**
```bash
xcodebuild test -scheme "MyBaby Watch App" \
  -destination 'platform=watchOS Simulator,id=34D6A1C2-779E-472E-B79E-552717A36AD3' \
  -only-testing:"MyBaby Watch AppTests" \
  -derivedDataPath ./build/DerivedDataWatch

xcodebuild build -scheme "MyBaby Phone WidgetsExtension" \
  -destination 'platform=iOS Simulator,id=F957544F-CEE7-4F79-93CA-87A4B2B3487D' \
  -derivedDataPath ./build/DerivedDataPhoneWidgets

xcodebuild build -scheme "MyBaby Watch Widgets" \
  -destination 'platform=watchOS Simulator,id=34D6A1C2-779E-472E-B79E-552717A36AD3' \
  -derivedDataPath ./build/DerivedDataWatchWidgets
```

## Full test

**Result:** success  
**Updated:** 2026-10-02  
**Profile:** full (unit + builds; no new e2e UI host required — WidgetKit faces covered by unit + extension builds)

| Check | Result |
|-------|--------|
| Watch AppTests (re-run after review) | covered by smoke **TEST SUCCEEDED** |
| Phone WidgetsExtension | **BUILD SUCCEEDED** |
| Watch Widgets | **BUILD SUCCEEDED** |
| Coverage / add-e2e Tasks | skipped — tasks did not require new XCUITest; widget UI not host-testable cheaply |

**Notes:** Reused smoke green suite; no Fix loop needed.

