# Grill: watch-widget-hig

## Result

**frontier-empty**

## Round 1 — frontier

❓ **Q1 — Rectangular title:** Drop “Baby Care” entirely vs keep a demoted caption?

➡️ Recommended: **Drop brand title on face** — user-first: kind + timer/age need the line; gallery still shows configurationDisplayName “Baby Care”.

❓ **Q2 — Circular overdue cue:** SF Symbol badge vs short “Overdue” / “!” text vs swap icon?

➡️ Recommended: **Short overdue text or symbol under/ beside primary** (match Phone small) — user-first: readable without color; avoid icon swap that loses care kind.

❓ **Q3 — Accent polish:** Keep hex teal/red vs system-style pass this pack?

➡️ Recommended: **Keep hex accents this pack** — user-first: meaning already learned; defer Always On contrast as Enhancement unless Build finds a fail.

## Scenario stress-test

| Scenario | Outcome |
|----------|---------|
| Fixed Care type Pump, never pumped | `mode.empty` → “No care yet”; VO uses empty summary |
| Running nap, VoiceOver on | Summary “Nap running” (shared helper) |
| Idle feed overdue, colorblind | Circular shows overdue cue + red; rectangular secondary already “Feed overdue” |

## Glossary / ADR

- No new glossary terms (reuse Care type / App Group mailbox / complication display).
- No ADR — reversible UI wiring pack; shared helpers already shipped.

## Settled decisions (Design must honor)

1. **Drop** rectangular face “Baby Care” title; keep widget configurationDisplayName.
2. **Circular overdue:** non-color text/symbol cue; keep kind icon; do not replace kind icon with “warning only”.
3. **Keep** hex teal/red this pack; accent polish Enhancement only.
4. **Wire** shared `accessibilitySummary` / `emptyPrimaryText` / `showsOverdueCue`; keep sample-on-nil store behavior.
5. **privacySensitive** on timer + relative ages.
6. Non-goals stand: no new families, no interactive log, no network, care rules/timeline unchanged.

## Auto-pick log

- `auto-pick — Q1 Drop title — user-first: glance kind+value; system: match Phone medium demote`
- `auto-pick — Q2 Overdue text/symbol keep kind icon — user-first: colorblind + still know Feed/Nap`
- `auto-pick — Q3 Keep hex — user-first: stable meaning; system: smaller diff`
