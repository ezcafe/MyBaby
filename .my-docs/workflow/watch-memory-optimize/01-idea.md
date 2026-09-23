# Idea: Lower MyBaby memory usage

## Problem

The MyBaby app uses too much memory (Watch and/or related targets). High memory risks jetsams, sluggish UI, and poor battery on watchOS.

## User / audience

Parents using MyBaby on Apple Watch (and related widget / shared targets). Developers maintaining the app.

## Outcome

Measurable lower memory footprint for the main care surfaces without changing care behavior or UI look. Keep logging, timers, and status updates correct.

## Metric

Lower peak / steady memory for Watch app (and widgets if they contribute) vs current baseline — Instruments Allocations / Memory Report, or equivalent Xcode memory gauge. No functional regressions on care actions.

## Has UI

**no** — memory / lifetime / caching / polling work only; no layout redesign.

## Lean / skip hints

- **Lean UI concept?** no
- **Copy/token-only?** no (not copy; no UI concept needed)

## 80/20 UI (day-to-day)

N/A — no UI

## Scope

- Find top memory consumers in MyBaby Watch App, widgets, and BabyCareShared
- Fix high-impact leaks, retained caches, over-eager timers/observers, large retained models/images
- Keep care rules and button behavior unchanged

## Non-goals

- New care features or UI polish
- Backend / my-apps API changes (unless Analyze proves a client cache issue only)
- Full rewrite of the app architecture

## Constraints

- watchOS memory budget is tight — prefer small, proven fixes
- Preserve existing care side effects and status snapshot behavior
- Prefer repo patterns already used in Watch / shared code
