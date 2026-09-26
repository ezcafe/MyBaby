# TDD test-case review: watch-picker-diaper-detail

**Result:** ok  
**Note:** main-thread fallback — usage limit

## Coverage vs tasks

| Task | Planned tests | Gap? |
|------|---------------|------|
| 1 Picker title center | Contract: title alignment center | none |
| 2 Tap plan + save mutation | Wet/Dry instant; Poop/Mixed openSheet; save omits nil color; amount default medium; Poop→dirty | none |
| 3 Sheet + model | Model builds action with detail keys; Wet still flash-only; Poop does not auto-save on chip tap | fold: add explicit “chip tap Poop does not call send until Save” if model API splits |
| 4 Smoke | Run unit suite | none |

## Suggested test names (Build)

- `customMlPickerTitleIsCentered`
- `planDiaperKindTapWetDryIsInstant`
- `planDiaperKindTapPoopMixedOpensSheetWithMedium`
- `diaperSheetSaveActionOmitsNilColorTexture`
- `diaperSheetSaveActionMapsPoopToDirty`
- `modelSelectDiaperWithDetailsIncludesAmount`
- `modelSelectDiaperWetDoesNotKeepSelected`

## Gaps / Fix ask

Folded into Task 3 acceptance: Poop/Mixed chip tap must **not** call live save until sheet Save (update `modelDiaperFlashOnly…` / add plan-driven test).

## Gate B note

Approve Design Option 1 + tasks + these tests. Confirm Build matches design (centered picker title; diaper sheet parity with my-apps). Skim System design (N/A) + Design patterns — OK.
