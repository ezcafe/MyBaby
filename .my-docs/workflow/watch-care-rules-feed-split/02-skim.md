# Light repo skim: watch-care-rules-feed-split

**Result:** done

## Project shape

watchOS Baby Care home: horizontal page `TabView` over `BabyHomePage` cases; timed chips + ml/diaper grids in `CarePages` / `CareControls`; status in `BabyHomeStatusModel` (local timers, sample snapshot). Widgets/deep links share `BabyCareShared`. Web rules live in my-apps quick-care (not wired on Watch yet).

## Constraints (≤5)

| Area | Constraint |
|------|------------|
| Pages | `BabyHomePage` + `BabyHomeView` TabView tags; deep link `queryValue` |
| Timers | `toggleTimed` / `selectBottle` / `selectDiaper` — no nap auto-end today |
| Chrome | `CareSectionHeader` detail = `.caption`; tips often `.caption2` |
| Tests | `MyBaby_Watch_AppTests` — extend for care matrix |
| Web parity | my-apps: non-pump → auto `endNap`; pump family skips; FORMULA/DIAPER/SLEEP stop breast |

## Reuse

| Existing | Use for |
|----------|---------|
| TimedCareChip / MlChipRow | Unchanged controls on split pages |
| CareFooterResolver | Footer priority unchanged |
| BABY_API / quick-care plan | Rule source for local side effects |
| Prior run `watch-baby-care-home` | IA baseline to extend |

## Avoid

- Inventing different nap/pump rules than web
- Nesting ScrollView in page TabView (breaks swipe)
- Scope-creeping GraphQL this pass
