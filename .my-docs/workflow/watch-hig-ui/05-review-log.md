# Code review log: watch-hig-ui

**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## Adversarial

**Result:** clean

| Sev | Finding |
|-----|---------|
| Enhancement | App Group may be nil in simulator without capability enrollment — store no-ops; widgets fall back to sample (documented) |
| Nit | Rectangular secondary assertion is loose — acceptable |

## Quality

**Result:** clean

| Sev | Finding |
|-----|---------|
| — | Matches HTML intent: verticalPage, backgrounds, Bottle/Amount sheets, Last care hero, short Connect, rect primary+secondary |
| Enhancement | Sleep page still has redundant `.environment(\.colorScheme, scheme)` — harmless |

**HTML drift:** none Critical/Major vs Gate A2 (Need help? is button toggle instead of DisclosureGroup — required for watchOS).

## Merged SPM (memory + perf)

**Result:** clean

| Lens | Notes |
|------|-------|
| Memory | ±1 page mount kept; TimelineView still chip-scoped; App Group DTO small |
| Perf | Widget reload on status/nap only; verticalPage may transfer scroll on Last care only |

## Fix ask

(none Critical/Major)

## Overall

**clean** — ready for Gate C
