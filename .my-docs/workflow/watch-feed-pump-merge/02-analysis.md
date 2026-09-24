# Analysis: Watch Feed/Pump page merge + scroll

**Size:** Prefer bullets. ≤5 solution pieces. Spike ≤5 rows. Stay within artifact size caps.

## Deep dive (required)

### Overall

#### What is this?
Re-merge Watch care home: Bottle controls onto Feed; Pump amount onto Pump; remove those two swipe pages; make Feed and Pump vertically scrollable. Keep care tap / side-effect rules unchanged.

#### Why do we need this?
Extra horizontal swipes slow night logging. Dense merged content clips on small faces without scroll. Skipping leaves the split IA users asked to undo.

#### How to do this?
Collapse `BabyHomePage` cases; merge page bodies in `CarePages`; wrap Feed/Pump in `ScrollView`; alias deep links; update README + tests.
- **Other ways:** Keep split pages and only add scroll (rejects user ask); or put amounts in sheets only (hides recommended chips).
- **Best practices:** Reuse `TimedCareChip` / `CareMlAmountGrid`; keep TabView ±1 mount; do not wrap TabView in TimelineView; alias old query values like prior deep-link work.

### Solution pieces

#### 1. Page enum + TabView strip

##### What is this?
Remove `.bottle` and `.pumpAmount` from `BabyHomePage` / `BabyHomeView`; remumber remaining cases.

##### Why do we need this?
Strip must match merged IA; `shouldMount` and tests key off raw values.

##### How to do this?
- Approach: Enum → feed, sleep, diaper, pump, lastCare. `fromQuery("bottle")` → `.feed`; `pump-amount` → `.pump`.
- Other ways: Keep ghost enum cases without TabView slots (confusing).
- Best practices: Update `queryValue` / tests / README together.

#### 2. Merged page bodies + ScrollView

##### What is this?
`FeedPage` = breast chips + bottle grid; `PumpPage` = timers + ml grid; delete `BottlePage` / `PumpAmountPage`.

##### Why do we need this?
One swipe per job; scroll reaches clipped controls.

##### How to do this?
- Approach: Compose existing controls in one `ScrollView`; one footer; Custom sheets stay.
- Other ways: Nested TabView vertical (worse gestures).
- Best practices: Honor Gate A #1 timers above fold; amounts next; verify horizontal swipe still works.

#### 3. Deep links + docs + tests

##### What is this?
Compat aliases + test/README updates; side-effect `.bottle` / `.pumpAmount` actions stay on model (not page enum).

##### Why do we need this?
Widgets/old URLs must not break; TDD locks order and aliases.

##### How to do this?
- Approach: Change `fromQuery` mapping; rewrite page-order / mount / deep-link tests; README page map.
- Other ways: Drop aliases immediately (breaks old links).
- Best practices: Keep `CareSideEffects` cases; only page identity changes.

## What exists today

Seven TabView pages including Bottle and Pump amount (`BabyHomeView` + `CarePages`). Deep links and tests assume seven cases. Side effects already distinguish bottle vs pump amount as **actions**, not pages.

## Dependencies

- Widgets / primary signal already deep-link to `.feed` / `.sleep` / etc. — verify no `.bottle` / `.pumpAmount` widget targets remain.
- README page map and deep-link string list.

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `BabyCareShared/BabyHomePage.swift` | Enum, query, deep link |
| `MyBaby Watch App/Views/BabyHomeView.swift` | TabView slots |
| `MyBaby Watch App/Views/Pages/CarePages.swift` | Merge + ScrollView |
| `MyBaby Watch App/Views/Components/CareControls.swift` | Reuse chips/grid |
| `MyBaby Watch AppTests/MyBaby_Watch_AppTests.swift` | Page order / mount / links |
| `README.md` | Page map |

## Reusable patterns (prefer in Design)

| Pattern / name | Where it lives | Why Design should reuse it |
|----------------|----------------|----------------------------|
| Page ±1 mount | `BabyHomePage.shouldMount` | Keep memory rule after remumber |
| Care page stack | `CarePages` VStack header→controls→footer | Merge without new chrome |
| Deep link aliases | `fromQuery` breast→feed etc. | Same for bottle→feed |

## System shape candidates (prefer in Design)

| Shape / concept | Where it lives | Why Design should teach it |
|-----------------|----------------|----------------------------|
| Local UI + Shared page identity | Watch App views + BabyCareShared | No new API/DB; Shared owns deep link enum |

## Constraints and risks

- ScrollView inside page TabView may fight horizontal swipe — verify on sim.
- Footer tip: use feed tip on Feed; pump tip on Pump (drop “Swipe for amounts.”).
- Do not change `CareSideEffects` matrix.

## Settled decisions (do not relitigate)

- Gate A2: merge Bottle→Feed, Pump amount→Pump, scroll Feed+Pump only.
- Has UI yes; Has API no; Has DB no (UI/page identity only).
- Keep deep-link aliases for `bottle` / `pump-amount`.

## Spike notes (optional)

N/A — composition is clear from existing pages.

## Has API / Has DB (for parent)

- **Has API:** no
- **Has DB:** no

## Clear enough to design?

yes — no blocking gaps.
