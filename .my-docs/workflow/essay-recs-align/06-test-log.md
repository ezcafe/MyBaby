# Test log: essay-recs-align

**Updated:** 2026-09-24

## Smoke

**Result:** smoke-pass

| Check | Result |
|-------|--------|
| my-apps unit (baby-age-guide, baby-home, baby-i18n, guidelines) | pass (74/74 targeted; full npm test pass 0 fail) |
| MyBaby Watch `xcodebuild build` (watchOS Simulator) | **BUILD SUCCEEDED** |
| MyBaby Watch AppTests (Series 10 46mm) | **TEST SUCCEEDED** (incl. CareGuide/essay fixtures EN/VI) |

## Lite test (Review profile lite)

**Result:** pass — unit coverage above; no new e2e required (copy/token + guide bands). Targeted existing baby-home tests updated.

## Notes

- Watch xcodebuild needs full permissions (DerivedData).
- Simulator id used: `AE5F3398-AAB0-4956-8316-926DE142CE77` (Series 10 46mm).
