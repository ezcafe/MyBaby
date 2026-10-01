# Performance lens: watch-security-perf

**Result:** clean  
**Round:** 1  
**Updated:** 2026-10-01  
**Scope:** Verify shared phone-security-perf Majors still shipped; flag Watch-specific thrash / regressions. Design Option 1 non-goals: do not re-implement Offline 80, desiredKeys, or coalescer.

**Skill:** `performance-optimization` (measure-first; this pass is verify-only — no new hot-path production code in draft).

| Area | Evidence | Verdict |
|------|----------|---------|
| Offline fetch cap | `OfflineCareFetchLimits.recentForStatus == 80`; `BabyHomeStatusModel.refreshOfflineSnapshot` → `fetchRecent(limit: OfflineCareFetchLimits.recentForStatus)` | ok — Major still shipped |
| CloudKit `desiredKeys` | `CloudKitOfflineCareStore.careEventDesiredKeys` set (kind/at/schemaVersion/side/ml/diaperKind/durationSec); `fetchRecent` passes it (not nil) + `resultsLimit: limit` | ok — Major still shipped |
| Widget reload coalesce | `persistStatusForWidgets` → App Group save then `widgetReloadCoalescer.schedule()` (~750ms); sole `reloadTimelines` call site is `SystemWidgetTimelineReloader` inside `WidgetTimelineReloadCoalescer` | ok — Major still shipped |
| Watch care refresh | `ContentView` offline `.task(id: mode)` → `refreshOfflineSnapshot`; `BabyHomeView` live → `loadLiveStatus`, non-live → coalesced persist only; comment + code: no `TimelineView` around TabView; timer ticks scoped to `TimedCareChip` label | ok — no new thrash |
| Draft delta | Task 1 ATS plist + Task 2 Leave-keeps-URL unit; `logout` still no hot-path work; non-goals honored | ok — no regression from this draft |

## Findings

No Critical / Major / Enhancement.

**FYI (do not Fix — out of Design Option 1):** Offline Start can call `refreshOfflineSnapshot` from `AuthConnectView.startOffline` and again from `ContentView` `.task(id: model.mode)`. Extra CloudKit read only; App Group write is cheap; WidgetKit still one coalesced wave. Pre-existing Watch wiring — not introduced by this draft. Deeper refresh/memory shaping stays in `watch-memory-optimize` if measured later.

## Fix ask

None.
