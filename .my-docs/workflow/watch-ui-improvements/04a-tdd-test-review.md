# TDD test-case review: watch-ui-improvements

**Result:** clean  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## Coverage vs tasks

| Task | Real scenarios | Edge scenarios | Enough? |
|------|----------------|----------------|---------|
| 1 Fail identity | Fail label keeps title + Failed subtitle | Timed + ml + diaper | yes |
| 2 Retry payload | Fail stores payload; retry same clientRequestId; success clears | Status-only fail → loadLiveStatus retry; Discard clears recovery | yes |
| 3 Loading | isStatusLoading around load | Error path clears loading | yes |
| 4 Settings sheet | No settings in strip; logout clears; deep link settings → sheet flag | Confirm path is UI — unit logout + page enum | yes |
| 5 Polish | ml label helper; Pump tip not dual | N/A | yes |

## Suggested test names (Build)

1. `failChipCopyKeepsIdentity` — title/subtitle for timed, ml, diaper
2. `sendFailStoresPayloadAndRetrySameId` — extend bottle fail
3. `statusFailRetryReloadsStatus` — mock client
4. `isStatusLoadingTogglesAroundLoad`
5. `babyHomePageStripHasFiveCarePages` — update allCases expectation
6. `deepLinkSettingsOpensSheetFlag` (or selectedPage unchanged + `showSettingsSheet`)
7. `logoutClearsTokenAndConnection`
8. `bottleChipLabelIncludesMl` / `pumpHeaderDetailNotDuplicateTip`

## Gaps / Fix ask

(none Critical/Major — Result clean)

## Gate B note

Human should confirm Option 1 design + tasks + these tests; Build must match approved HTML.
