# Test log: watch-memory-optimize

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-09-23

- Build + unit: `xcodebuild test` · scheme `MyBaby Watch App` · destination Apple Watch Series 10 (46mm) OS 11.5 · **TEST SUCCEEDED**
- New tests green: `careTimerTicksOnlyWhenRunningSelectedAndActive`, `modelSecondDoneFlashCancelsPriorClearTask`, `modelAmountFlashCancelsPriorSideClearTask`
- Suite includes prior care-matrix / timeline cases (all passed)

## Memory re-measure (Task 5)

**Baseline (user):** Debug Navigator · MyBaby Watch App · Current **22.3 MB** · High **22.4** · Low **2.6**

**After hygiene:** Not re-captured in this agent session (needs Xcode Debug Navigator on running app).  
**Expectation recorded:** Debug peak may stay ~22 MB; primary gate = no growth under nap + unit green.

## Lite test

**Result:** success  
**Updated:** 2026-09-23

- Review profile **lite** — targeted unit suite (above) is the automated gate; no new e2e required by tasks.
- Manual: re-check Memory Report after launch + nap on Sleep page (user).

## Fix ask

None.
