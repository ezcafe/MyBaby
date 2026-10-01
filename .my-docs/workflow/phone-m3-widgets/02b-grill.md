# Grill: phone-m3-widgets

**Result:** frontier-empty  
**HITL:** auto (Grill prefer-auto; user-first) despite Gate B blocking for Design approval later

## Round 1 frontier (auto-settled)

❓ **N1** — Phone widget kind string  
➡️ **Recommended:** new kind `BabyCarePhoneHome` + dual reload with Watch `BabyCareComplication` — user-first: Phone refresh must not depend on Watch kind existing; system: clear constants in Shared.

❓ **N2** — Widget families  
➡️ **Recommended:** `systemSmall` + `systemMedium` only in M3 — user-first: covers glance + one secondary line; system: skip large until needed.

❓ **N3** — Care-type AppIntent location  
➡️ **Recommended:** Phone Widgets local AppIntent mirroring Watch cases; reuse Shared `BabyCareComplicationCareType` / display — user-first: same Care type labels; system: no Watch↔Phone target merge.

❓ **N4** — Stub ControlWidget + Live Activity  
➡️ **Recommended:** remove from `WidgetBundle` (and leave files unused or delete) — user-first: gallery shows only Baby Care; system: less confusion.

## Scenario stress-test

1. **Timer running, leave app:** persist writes DTO + reloads Phone kind → Home Screen `.timer` advances without open app.
2. **Empty App Group (fresh install widget before open app):** placeholder/sample — no crash, no secrets.
3. **Care type Feed fixed while nap running:** Feed filter shows feed last-care or feed timer only — Auto would prefer nap; fixed Feed must not show nap (match Watch resolve).

## Settled decisions

| ID | Pick | Rationale |
|----|------|-----------|
| N1 | Kind `BabyCarePhoneHome` + dual reload | Honest Phone refresh |
| N2 | systemSmall + systemMedium | M3 glance scope |
| N3 | Phone-local intent; Shared display/careType | Parity without target merge |
| N4 | Strip Control + Live Activity from bundle | Clean gallery |

## Glossary / ADR

- No new glossary terms beyond existing App Group / Offline (already known).
- **ADR:** none — kind string + families are reversible; not surprising enough for ADR bar.

## Frontier after round

**empty** — proceed to Design.
