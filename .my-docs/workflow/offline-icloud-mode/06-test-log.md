# Test log: offline-icloud-mode

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-09-29  
**Note:** main-thread Build; `xcodebuild build-for-testing` + `xcodebuild test`

| Check | Result |
|-------|--------|
| build-for-testing (watchOS Simulator) | pass |
| Unit tests `MyBaby Watch AppTests` (Series 10 46mm OS 11.5) | pass (`** TEST SUCCEEDED **`) |

Includes new OfflineCareStoreTests + Connect Offline/Cloud defaults.

## Full / lite

**Result:** success  
**Profile:** full (unit suite; Watch UI e2e not required for this pass)

| Check | Result |
|-------|--------|
| Unit `MyBaby Watch AppTests` | pass |
| New Offline / Connect cases | pass |
| CloudKit on-device | manual — needs iCloud sign-in + container capability |

## Failures (if any)

None.

## Fix ask for my-code-workflow

None.
