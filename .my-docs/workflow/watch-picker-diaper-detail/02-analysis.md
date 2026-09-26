# Analysis: watch-picker-diaper-detail

**Mode:** simple · **Note:** main-thread fallback — usage limit after Analyze Task retry

## Overall — What / Why / How

1. **What is this?** Two Watch UI fixes: center `CustomMlPicker` title; make Diaper Poop/Mixed open a detail sheet (color / texture / amount) like my-apps baby home, while Wet/Dry stay one-tap.
2. **Why do we need this?** Left title looks off-center on sheets. Instant Poop/Mixed skips health detail caregivers expect from web; parity reduces “Watch forgot the dialog” confusion.
3. **How to do this?** (a) Change picker title `alignment` to `.center`. (b) Port my-apps `planBabyDiaperKindTap` + sheet save mutation into Watch model/UI; reuse existing `.sheet` pattern from Bottle/Pump; extend `selectDiaper` action dict with optional `diaperColor` / `diaperTexture` / `diaperAmount` (already on server `BabyQuickCareInput`). **Alt:** open sheet for all four kinds — reject (breaks Wet/Dry speed + web S1). **Best:** match `lib/baby-diaper-quick-plan.ts` exactly.

## Deep dive by piece

### A — Center picker title

| | |
|--|--|
| **What** | `CustomMlPicker` title Text uses `.frame(maxWidth: .infinity, alignment: .leading)` in `CarePages.swift` |
| **Why** | User wants horizontal center; Bottle + Pump custom sheets share this view |
| **How** | Set `alignment: .center` (and/or `multilineTextAlignment(.center)`). Unit: assert static contract or source test. **Alt:** navigationTitle — heavier, changes chrome. |

### B — Diaper tap plan (parity)

| | |
|--|--|
| **What** | Today `DiaperKindGrid` → `model.selectDiaper(kind)` always sends kind-only and flashes done |
| **Why** | my-apps: Wet/Dry `instantSave`; dirty/mixed `openSheet` with defaults color/texture null, amount `medium` |
| **How** | Pure helper `planDiaperKindTap` (Swift mirror of `planBabyDiaperKindTap`). View: Wet/Dry call save; Poop/Mixed present sheet. Save builds mutation via mirror of `babyDiaperSheetSaveMutation`. |

### C — Detail sheet UI (Watch)

| | |
|--|--|
| **What** | New sheet: color chips, texture chips, amount chips, Cancel/Save; optional red-flag / caution captions |
| **Why** | Same meaning as `BabyDiaperDetailSheetForm`; Watch must fit small scroll |
| **How** | `.sheet` on `DiaperPage` (like Bottle/Pump). ScrollView + chip grids; default amount medium; optional color/texture toggle-off. **Alt:** multi-step wizard — more taps, reject for parity. **Density:** full enum lists from my-apps (`lib/baby-diaper-detail.ts`); scroll OK on Watch. |

### D — Live send payload

| | |
|--|--|
| **What** | `selectDiaper` action is `{ kind: DIAPER, diaperKind }` only |
| **Why** | Server already accepts optional color/texture/amount for dirty/mixed (`features/baby/server/quick-care.ts`, GraphQL enums) |
| **How** | On sheet Save, pass those keys in action JSON. Sample mode: flash done without network. No new endpoint. |

## Decision lean (for Design)

### Decision 1: sheet density on Watch

#### Option 1 — Full parity chips (recommended)
- **What it is:** Same color / texture / amount enums as web; scrollable sheet.
- **Example:** Poop → sheet with all colors + textures + smear/medium/blowout → Save.
- **Pros:** True parity; one mental model with my-apps.
- **Cons:** Tall sheet; more scrolling on small Watch.

#### Option 2 — Amount-only Watch sheet
- **What it is:** Only amount required; skip color/texture on Watch.
- **Example:** Poop → amount chips → Save with default medium + no color.
- **Pros:** Faster on wrist.
- **Cons:** Not “same as my-apps”; user asked for more details like web.

**Recommendation:** Option 1.

## Reusable patterns

- Watch: `CustomMlPicker` + `.sheet` on Feed/Pump pages
- Watch: `selectDiaper` / `sendQuickCare` / fail control `.diaper(kind)`
- my-apps: `planBabyDiaperKindTap`, `babyDiaperSheetSaveMutation`, `baby-diaper-detail` enums + toggles

## System shape candidates

1. **View-owned sheet state + model save API** (recommended) — `@State showDiaperDetail` + kind; model `selectDiaper(_:details:)` or `saveDiaperDetail(...)`
2. **Model-owned sheet flags** — heavier; only needed if deep links open sheet

## Spike notes

N/A — server fields confirmed via my-apps GraphQL / quick-care; Watch client already posts arbitrary action dict.

## Has API / Has DB

- **Has API:** no — existing `babyQuickCare` / `BabyQuickCareInput` fields only; no new public contract
- **Has DB:** no

## Clear enough to design?

**yes** — picker fix trivial; diaper plan + sheet + payload mapping clear. Design locks Option 1 density + task list + tests.

## Key file paths

| Path | Role |
|------|------|
| `MyBaby Watch App/Views/Pages/CarePages.swift` | `CustomMlPicker`, `DiaperPage` |
| `MyBaby Watch App/Views/Components/CareControls.swift` | `DiaperKindGrid` |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | `selectDiaper`, `DiaperKind` |
| `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift` | Existing diaper / picker tests |
| `my-apps/lib/baby-diaper-quick-plan.ts` | Tap plan + save mutation |
| `my-apps/lib/baby-diaper-detail.ts` | Enums + defaults |
| `my-apps/components/baby-diaper-detail-sheet.tsx` | Sheet UX reference |
| `my-apps/lib/graphql/baby-typeDefs.ts` | `diaperColor` / `diaperTexture` / `diaperAmount` on input |
