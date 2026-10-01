# Test log: phone-m1-shell-connect

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-09-30

| Check | Result |
|-------|--------|
| `xcodebuild` MyBaby Phone App (iPhone 16 / iOS 18.2 sim) | BUILD SUCCEEDED |
| `PhoneSessionModelTests` (7 cases, Watch AppTests host) | all passed |

Notes: Phone target is now `com.apple.product-type.application`. Session model lives in `BabyCareShared` for shared TDD.

## Full / lite

**Result:** success (lite profile path used as full Mode with targeted unit + Phone build)  
**Updated:** 2026-09-30

| Suite | Result |
|-------|--------|
| PhoneSessionModelTests (7) | pass |
| Phone App build | pass |
| Watch e2e / UITest for Phone | N/A this milestone (unit + build smoke) |

**Overall test Result:** success
