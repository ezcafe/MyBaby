# Test log: phone-widget-hig

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-10-01

| Check | Result |
|-------|--------|
| Unit (`MyBaby Watch AppTests`) | **TEST SUCCEEDED** · 165 passed (incl. a11y/empty/overdue) |
| Phone App + WidgetsExtension | **BUILD SUCCEEDED** (`iPhone 16` id F957544F…) |

Commands:
- `xcodebuild test -scheme "MyBaby Watch App" -destination 'platform=watchOS Simulator,id=AE5F3398-…' -only-testing:"MyBaby Watch AppTests" -derivedDataPath ./build/DerivedDataWatch`
- `xcodebuild build -scheme "MyBaby Phone App" -destination 'platform=iOS Simulator,id=F957544F-…' -derivedDataPath ./build/DerivedDataPhone`

## Full test

**Result:** success  
**Notes:** Same unit suite as smoke (165). No separate e2e for WidgetKit; Phone build covers Lock Screen families compile.

## Fix ask

None.
