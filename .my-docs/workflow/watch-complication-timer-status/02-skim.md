# Light repo skim: watch-complication-timer-status

**Result:** done
**Updated:** 2026-09-27

## Project shape

MyBaby Watch logs care in-app; complications are a WidgetKit extension that **only** reads App Group `BabyCareStatusDTO` (no network). The Watch app writes the DTO via `persistStatusForWidgets()` after status load and some timer changes (nap today).

## Related UI paths

| Path | Role |
|------|------|
| `MyBaby Watch Widgets/BabyCareWidgets.swift` | Provider + all accessory families |
| `BabyCareShared/BabyCareStatusStore.swift` | App Group mailbox |
| `BabyCareShared/BabyCareWidgetTimeline.swift` | Rebuild policy (~1 min nap) |
| `BabyCareShared/BabyHomeStatusSnapshot.swift` | `BabyCarePrimarySignal` |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | Timer phases + persist |

## Related APIs / data

| Item | Note |
|------|------|
| App Group `group.vn.in4.MyBaby` | Status DTO only — no token |
| GraphQL homeQuickStatus | App refresh only; not widgets |
| `feedOverdueSeconds` / `diaperOverdueSeconds` | Existing out-of-range signals |
| Breast/pump `TimedChipPhase.running` | In model; **not** in DTO yet |

## Hard constraints

- No network from widget; no APNs this pass
- One kind `BabyCareComplication`; families: circular / corner / rectangular / inline
- Prefer `Text(date, style: .timer)` for live elapsed — not 1 Hz TimelineView in widget
- Keep deep links `mybaby://home?page=…`

## Risks if ignored

- Face stays stale while breast/pump runs (DTO lacks those starts)
- Static formatted timer looks frozen between timeline rebuilds
- Red/teal illegible on Always On / tiny circular

## Enough for UI concept / Analyze?

yes
