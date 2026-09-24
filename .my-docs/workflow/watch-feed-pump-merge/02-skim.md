# Light repo skim: watch-feed-pump-merge

**Result:** done
**Updated:** 2026-09-24
**Size:** keep ≤ ~40 lines (cap) — short tables (≤5 rows each)
**Purpose:** constraints only — ground Gate A2 / UI concept / Analyze in what already exists. Not a full analysis.

## Project shape (1–3 sentences)

watchOS Baby Care home: horizontal page-style `TabView` over `BabyHomePage` cases; timed chips + ml grids in `CarePages` / `CareControls`; local timers in `BabyHomeStatusModel` with sample snapshot. Deep links and widgets share `BabyCareShared`. GraphQL not required for this UI merge.

## Related existing UI / screens

| Path | What it does | Reuse? |
|------|--------------|--------|
| `MyBaby Watch App/Views/BabyHomeView.swift` | TabView page strip + mount ±1 | yes — drop bottle/pumpAmount slots |
| `MyBaby Watch App/Views/Pages/CarePages.swift` | Feed/Bottle/Pump/PumpAmount bodies | yes — merge into Feed + Pump |
| `MyBaby Watch App/Views/Components/CareControls.swift` | Chips, ml grid, footer | yes |
| Prior ui-refs under `watch-care-rules-feed-split/ui-refs/` | Feed / Bottle screenshots | yes — base for Gate A2 |
| `README.md` | Page map + deep links | yes — update after merge |

## Related APIs / data

| Path or route | Notes |
|---------------|-------|
| `BabyCareShared/BabyHomePage.swift` | Enum + `queryValue` / `fromQuery` / deep link |
| `BabyCareShared/CareSideEffects.swift` | `.pumpAmount` action flag (keep behavior) |
| Sample snapshot / chip mls | No new server contract |

## Hard constraints (do not fight)

1. Do not wrap TabView in TimelineView — gesture cancel risk (comment in BabyHomeView).
2. Mount only selected ±1 neighbor (`shouldMount`) — remumber pages after remove.
3. One footer slot per page; no app title chrome.
4. Care tap rules already ported — do not change side effects in this pass.
5. ui-refs must match real Watch chrome (prefer screenshots / prior real refs).

## Risks if we ignore the repo

- Broken deep links / widget taps for `bottle` and `pump-amount`.
- `shouldMount` / page rawValue tests fail after enum shrink.
- Nested ScrollView vs page TabView may fight horizontal swipe if ignored.

## Enough for UI concept / Analyze?

yes — merge Feed+Bottle and Pump+PumpAmount; add vertical scroll; update enum/deep links/README/tests.
