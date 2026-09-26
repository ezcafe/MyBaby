# Code review log: watch-ui-improvements

**Result:** clean  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit; SPM plan none

## Adversarial

**Result:** clean

| Severity | Finding | Note |
|----------|---------|------|
| Nit | Diaper fail + Failed subtitle may crowd 44pt tile | Acceptable; caption2 floor |
| Nit | `isStatusLoading` not asserted mid-flight | defer OK |

## Quality

**Result:** clean

| Check | Pass? | Note |
|-------|-------|------|
| HTML ui-refs parity | yes | Fail identity, Retry, sheet, presets |
| Settings Option B | yes | No Settings page; gear sheet |
| Retry same clientRequestId | yes | Tests green |
| Logout confirm | yes | confirmationDialog |
| Token not shown in sheet | yes | Host only |

## Merged SPM

**Result:** skipped — SPM plan none

## Fix ask

(none)
