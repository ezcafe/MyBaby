# Performance lens: phone-security-perf

**Result:** clean  
**Updated:** 2026-10-01

| Area | Note |
|------|------|
| Offline fetch | `OfflineCareFetchLimits.recentForStatus == 80` |
| CloudKit keys | `careEventDesiredKeys` set (not nil) |
| Widget reload | `WidgetTimelineReloadCoalescer` ~750ms; App Group save immediate |

No Critical/Major. No Fix ask.
