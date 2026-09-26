# Light repo skim: watch-ui-improvements

**Result:** done  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## Project shape

MyBaby WatchOS 10+ SwiftUI app: paged care home (`BabyHomeView` TabView), chips in `CareControls`, pages in `CarePages`, connect in `AuthConnectView`, tokens in `BabyTokens`, model in `BabyHomeStatusModel`. Widgets are sample-timeline companions.

## Constraints (≤5)

| Constraint | Where | Impact |
|------------|-------|--------|
| Page mount ±1 neighbor | `BabyHomePage.shouldMount` | Removing Settings shrinks strip; update deep link `settings` |
| Footer Retry unused | `CareFooterSlot` + CarePages | Wire `onRetry` / model retry |
| Gear → Connect today | `ContentView` / `BabyHomeView` | Option B: gear → sheet; Reconnect → Connect |
| Fail replaces title | `TimedCareChip` / grids | Keep identity; Failed subtitle |
| Secondary 11pt / diaper 10pt | `BabyTokens` / DiaperKindGrid | Prefer caption2 floor |

## Reuse

| Pattern | Path | Use for |
|---------|------|---------|
| `BabyPalette` / chips | Theme + CareControls | Sheet chrome + fail + presets |
| `CareFooterSlot` | CareControls | Retry / Discard |
| `logout` / `needsReconnect` | BabyHomeStatusModel | Sheet Log out / Reconnect |
| `BabyHomePage` | Shared | Drop `.settings` from strip |

## Risks

- Deep link `page=settings` → map to feed or open sheet
- ProgressView during TabView — keep light; avoid TimelineView on TabView
