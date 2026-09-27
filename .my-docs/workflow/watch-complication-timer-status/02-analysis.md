# Analysis: watch-complication-timer-status

**Updated:** 2026-09-27  
**Has API recommendation:** no — App Group + WidgetKit only; GraphQL shape already returns `at` on last events  
**Has DB recommendation:** no — no schema / migrations

## Overall deep dive

### What is this?
Make Baby Care complications show a **live** care-timer when one is running in the Watch app, and when idle show **last care time** in **teal** (in range) or **red** (out of range), on all accessory families.

### Why do we need this?
Raise-wrist glance is the product. Today the face can freeze a nap string for ~1 min, ignore breast/pump timers (not in App Group), and does not use color for “OK vs overdue.”

### How to do this?
- Persist running timer start + kind into App Group whenever nap/breast/pump starts or stops.
- Widget: `Text(startDate, style: .timer)` while running (Gate A2 / prior recommendation).
- Idle: pick latest care `at`; color from recommendation/overdue band (CareGuide + parsed dates — mapper currently leaves `feedOverdueSeconds` nil).
- Other ways: per-second timeline entries (reject); APNs wake (out of scope); network-from-widget (reject — skim).
- Best practices: App owns freshness; widgets read-only; system dynamic dates (WWDC WidgetKit).

## Solution pieces

### 1. App Group DTO + model persist

| | |
|--|--|
| **What** | Extend `BabyCareStatusDTO` with running timer kind + start; optional last-event dates; write on every timer toggle |
| **Why** | Breast/pump never call `persistStatusForWidgets` today — face cannot reflect them |
| **How** | Add fields; call `persistStatusForWidgets()` from breast/pump start/stop (nap already does). Keep no secrets |
| **Other** | File coordination vs UserDefaults — keep UserDefaults suite (existing) |
| **Best practice** | Version DTO; suiteName injectable for tests |

### 2. Primary signal + color band

| | |
|--|--|
| **What** | Resolver: running timer → idle last-care + in/out color |
| **Why** | Gate A2 states; current `BabyCarePrimarySignal` prefers nap then overdue then next feed then last sentence — no live `.timer` date, no teal/red |
| **How** | Priority: any running timer (nap > breast > pump) → else last care by max(`at`); out-of-range if feed/diaper overdue (compute from `at` + CareGuide intervals if server fields still nil) |
| **Other** | Keep next-feed as primary idle (rejects Gate A2 “last care + color”) |
| **Best practice** | Pure functions + unit tests (existing primarySignal tests) |

### 3. Widget views (all families)

| | |
|--|--|
| **What** | Circular / corner / rectangular / inline match `_proposed-complications.html` |
| **Why** | Approved look; one kind already covers families |
| **How** | `Text(start, style: .timer).monospacedDigit()` + teal/red foreground; rect brand + secondary |
| **Other** | Static `formatTimer` + 1 min reload (current — fails live requirement) |
| **Best practice** | Dynamic dates; timeline policy only for state changes / overdue boundary |

## Reusable patterns

- `BabyCareStatusStore` App Group mailbox
- `persistStatusForWidgets` + `WidgetCenter.reloadTimelines`
- `BabyCarePrimarySignal` pure resolver + tests
- `BabyTokens.accent` / `danger`

## System shape candidates

- Unchanged: Watch app → GraphQL; widgets ← App Group
- No new process; no Has API/DB

## Spike notes

N/A this pass — `.timer` on accessory is Apple-supported; risk is layout truncation (monospacedDigit / short labels).

## Gaps / clarity

- Instructions clear enough to design? **yes** (Gate A2 + idea defaults).
- Mapper sets overdue/nextFeed to **nil** today — Design must compute client-side from `at` + CareGuide or wire mapper; prefer client-side from existing `at` in GraphQL payload.
- Exact feed interval for “in range” — use CareGuide stage / bottle band or existing tip intervals; Design picks one table.

## Open for Design

1. Timer priority nap > breast > pump (confirm).
2. Idle primary always last care (not next-feed) per Gate A2.
3. Compute overdue client-side from last feed/diaper `at`.
