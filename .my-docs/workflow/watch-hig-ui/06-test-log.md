# Test log: watch-hig-ui

## Smoke

**Command:**  
`xcodebuild -scheme "MyBaby Watch App" -destination 'generic/platform=watchOS Simulator' -derivedDataPath .derivedData build`  
then  
`xcodebuild test -scheme "MyBaby Watch App" -destination 'platform=watchOS Simulator,id=AE5F3398-AAB0-4956-8316-926DE142CE77' -derivedDataPath .derivedData`

**Outcome:** **BUILD SUCCEEDED** · **TEST SUCCEEDED**

**Notes:** Includes HIG helpers (background, status store, hero/secondary), existing care/live suites, UITests. DisclosureGroup replaced with Need help? toggle (unavailable on watchOS).

## Full test

**Note:** Watch target — unit + UITest suite is the automated suite (no separate Playwright e2e). Re-used smoke **TEST SUCCEEDED**. Coverage / add-e2e N/A.

## Fix ask

(none)
