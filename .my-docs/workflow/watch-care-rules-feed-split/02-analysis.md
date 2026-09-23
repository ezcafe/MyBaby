# Analysis: Watch care rules + Feed/Bottle split

**Size:** Prefer bullets. ≤5 solution pieces.

## Deep dive (required)

### Overall

#### What is this?
Align MyBaby Watch home with web baby-home care side effects; split Feed vs Bottle pages; Bottle/Pump show 2 recommended ml + Custom (same chip-build rule, `limit: 2`); quieter section detail font; **remove** app title chrome.

#### Why do we need this?
Wrong local timers (nap stays open while feeding) break night trust vs phone. Crowded Feed+Bottle page and loud subtle copy hurt one-thumb Watch use.

#### How to do this?
- Split `BabyHomePage.feedBottle` → `.feed` + `.bottle`; update TabView, deep links, primary-signal deep links.
- Add a pure **local care side-effect** helper (mirror my-apps quick-care): non-pump actions end open nap; bottle/diaper/sleep stop breast; pump family leaves nap + breast alone.
- Port `buildBabyBottleChipMls` logic into Shared (or thin Swift twin) with `limit: 2`; wire Bottle + Pump.
- `CareSectionHeader` detail → `.caption2`; drop `.navigationTitle`.
- **Other ways:** Call real `babyQuickCare` now (blocked — no API wire this pass). Encode rules only in each button handler (duplicates, easy to drift).
- **Best practices:** Keep side effects in one pure function + unit tests (web already does plan/localAfter); Watch UI stays thin.

**Has API:** no — local model only this pass.  
**Has DB:** no.

### Solution pieces

#### 1. Page IA + deep links

##### What is this?
Six pages: Feed, Bottle, Sleep, Diaper, Pump, Last care; no app title.

##### Why do we need this?
Gate A2 lock; one job per swipe; `page=bottle` must work.

##### How to do this?
- Approach: extend `BabyHomePage`; `BabyHomeView` tags; map `feed`/`breast`→feed, `bottle`→bottle; default landing `.feed`.
- Other ways: keep one page with vertical sections (rejected at A2).
- Best practices: update widgets/deep-link helpers that still reference `.feedBottle`.

#### 2. Local care side effects (nap / breast / pump)

##### What is this?
On breast/bottle/diaper (and sleep start conflicts): end open nap; stop breast when bottle/diaper/sleep need it; pump never auto-ends nap.

##### Why do we need this?
User example: Feed stops sleep timer — web `quick-care` non-pump → `endNap`.

##### How to do this?
- Approach: `CareSideEffects.apply(action:state:)` pure; call from `toggleTimed` / `selectBottle` / `selectDiaper` before/after phase changes.
- Other ways: only end nap on bottle save, not breast start (conflicts with web BREAST auto-end).
- Best practices: table-driven unit tests matching web matrix; pump family explicit skip.

#### 3. Bottle / Pump ml chips (limit 2)

##### What is this?
Two recommended ml + Custom; history-first then snaps (web `buildBabyBottleChipMls`).

##### Why do we need this?
Watch space; user lock; match recommendation rule not raw `[60,90,120]` always.

##### How to do this?
- Approach: Swift `BabyBottleChipMls.build(recent:snaps:limit:)` in Shared; snapshot holds `bottleChipMls` / reuse for pump; sample uses limit 2.
- Other ways: hard-code two mids (drifts from age guide).
- Best practices: port tests from `lib/baby-age-guide.test.ts` for limit 2.

#### 4. Section subtle type + remove title

##### What is this?
Detail under section lead smaller; no nav title string.

##### Why do we need this?
Gate A2; free vertical space for chips.

##### How to do this?
- Approach: `CareSectionHeader` detail `.caption2`; remove `.navigationTitle` (or empty); ageTitle helper can remain unused or for future status.
- Other ways: keep title top-left (rejected — remove).
- Best practices: keep footer tips at `.caption2` consistent.

#### 5. Tests

##### What is this?
Unit matrix for side effects, chips, pages/deep links; adjust age-title tests if title unused.

##### Why do we need this?
TDD gate; prevent rule drift.

##### How to do this?
- Approach: expand `MyBaby_Watch_AppTests`; Shared tests if chip builder lives there.
- Other ways: UI-only manual (fails workflow).
- Best practices: failing tests before production changes.

## What exists today

Watch TabView over `feedBottle|sleep|diaper|pump|lastCare`; timers in `BabyHomeStatusModel` with **no** cross-care side effects; bottle chips fixed `[60,90,120]`; section detail `.caption`; title via `.navigationTitle`. Web rules in `baby-quick-care-plan.ts` + `quick-care.ts` + `buildBabyBottleChipMls`.

## Dependencies

- Widget deep links / `BabyCarePrimarySignal.deepLinkPage` still point at `.feedBottle` — update.
- Sample snapshots need `recentBottleMl` or snaps for chip builder.
- Existing WIP on CarePages/Model — Build absorbs into this design.

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `BabyCareShared/BabyHomePage.swift` | Page enum + deep links |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | Side effects entry |
| `MyBaby Watch App/Views/Pages/CarePages.swift` | Split Feed/Bottle pages |
| `MyBaby Watch App/Views/BabyHomeView.swift` | TabView + remove title |
| `MyBaby Watch App/Views/Components/CareControls.swift` | Subtle font |
| `BabyCareShared/BabyHomeStatusSnapshot.swift` | Chip mls fields |
| `my-apps/lib/baby-age-guide.ts` | Chip algorithm |
| `my-apps/lib/baby-quick-care-plan.ts` | localAfter rules |
| `my-apps/features/baby/server/quick-care.ts` | endNap unless pump |

## Reusable patterns (prefer in Design)

| Pattern / name | Where it lives | Why Design should reuse it |
|----------------|----------------|----------------------------|
| Pure signal/resolver | `BabyCarePrimarySignal` | Same style for side-effect helper |
| CareFooterResolver priority | Model | Keep footer single-slot |
| TimedCareChip / MlChipRow | CareControls | No new chip chrome |
| buildBabyBottleChipMls | my-apps age-guide | Port, don’t invent |

## System shape candidates (prefer in Design)

| Candidate | Fit | Note |
|-----------|-----|------|
| Local pure helper + Observable model | best | No API this pass |
| Full quick-care client port | later | When GraphQL lands |

## Open questions for Design

- None blocking — Gate A2 locks clear. Sample `recentBottleMl` can be empty → snaps `[60,90]` with limit 2.

## Clarity check

Instructions clear enough to design: **yes**. Has API **no**, Has DB **no**.
