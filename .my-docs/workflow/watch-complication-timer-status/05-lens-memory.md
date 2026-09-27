# Memory lens: watch-complication-timer-status

**Result:** clean  
**Updated:** 2026-09-27

- No periodic TimelineView in widget extension.
- Live digits via `Text(date, style: .timer)`.
- App Group DTO v2 adds timer + last*At fields only (no large caches).
- `reloadTimelines` on persist only (timer start/stop / status load).
