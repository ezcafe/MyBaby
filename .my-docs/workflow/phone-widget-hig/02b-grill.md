# Grill: phone-widget-hig

## Result

**frontier-empty**

## Round 1 — frontier

❓ **Q1 — Families scope:** Home Screen pack only vs also Lock Screen accessory vs also systemLarge?

➡️ Recommended: **Home Screen only** — user-first: fix glance a11y/empty/overdue where parents already place the widget; Lock Screen privacy + Large density can wait.

❓ **Q2 — A11y API home:** Shared `BabyCareComplicationDisplay` helper vs Phone-widget-local strings?

➡️ Recommended: **Shared display helper** — user-first: one VoiceOver meaning; system: Watch can adopt later without a second ruleset.

❓ **Q3 — Nil mailbox:** Keep sample fallback for empty App Group, or show empty copy when nil?

➡️ Recommended: **Keep sample fallback** for nil mailbox (gallery/preview honesty); fix **mode.empty** live “·” only — user-first: do not show fake “No care yet” when the store still falls back to demo sample.

## Scenario stress-test

| Scenario | Outcome |
|----------|---------|
| Fixed Care type Pump, never pumped | `mode.empty` → clear “No care yet” / kind empty; VO announces empty |
| Running nap, VoiceOver on | Summary includes Nap + timer meaning |
| Idle feed overdue, colorblind | Small shows overdue text/symbol; medium secondary already says overdue |

## Glossary / ADR

- No new glossary terms required (reuse Baby Care / Care type / App Group mailbox).
- No ADR — reversible UI pack; families deferred are product scope, not hard architecture.

## Settled decisions (Design must honor)

1. **Home + Lock Screen accessory** — Gate B user chose Option 2 (overrides Grill Q1 Home-only). No systemLarge.
2. **Shared** `accessibilitySummary` (name may vary) on `BabyCareComplicationDisplay`.
3. **Keep** `snapshotForWidgets` sample-on-nil; fix empty **mode** primary copy only.
4. Non-goals stand: no interactive log, no network, no Live Activities, care rules unchanged.
5. Lock Screen values use `privacySensitive` where care times show.

## Auto-pick log

- `auto-pick — Q1 Home-only — user-first: …` → **superseded** by Gate B Option 2
- `auto-pick — Q2 Shared helper — user-first: consistent VO meaning; system: one ruleset`
- `auto-pick — Q3 Keep sample-on-nil — user-first: avoid lying empty when mailbox never written; system: match current store`
- **20:20** · Gate B — user Option 2 — Home + Lock Screen accessory
