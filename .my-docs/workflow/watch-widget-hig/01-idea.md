# Idea: Watch Widget HIG + best-practices pack

## Project shape (quick scan)

MyBaby Watch App embeds **MyBaby Watch Widgets**. One kind `BabyCareComplication` ships all accessory families: circular, corner, rectangular, inline (face + Smart Stack). Care type Auto | Feed | Sleep | Diaper | Pump via App Intent. Reads App Group `group.vn.in4.MyBaby` (no network). Live `.timer` when a care timer runs; idle last-care with teal/red; tap deep-links into care pages. Shared display/timeline helpers live in `BabyCareShared/` — Phone HIG pack already added `accessibilitySummary`, `emptyPrimaryText`, and `showsOverdueCue` there; Watch views do not wire them yet.

## Problem

Watch complications work for basic glance (timer + last care + color), but they do not fully follow Apple Widgets / Accessibility HIG practices caregivers need on the wrist:

- VoiceOver has no combined label (Phone widgets already use `display.accessibilitySummary`).
- Overdue on circular / corner / inline relies heavily on **color alone** (red vs teal); rectangular alone says “X overdue”.
- Empty faces still show cryptic “·” in primary value paths, while shared code already defines `emptyPrimaryText` (“No care yet”).
- Rectangular puts a **“Baby Care”** brand title above kind + value, fighting glance hierarchy on a tiny accessory.
- Care times are not marked `privacySensitive` (Phone Lock Screen / Home paths already do).
- Hard-coded hex accents may fight Always On / redacted accessory chrome more than system styles would.

Parents need a glanceable, accessible, Apple-shaped wrist companion — not a mini app, and not behind Phone widgets on a11y/empty/privacy.

## User / audience

Parents / co-caregivers who already use MyBaby Watch care home and glance face complications or Smart Stack between logs — often one-handed, low light, holding a baby, raising the wrist for 1–2 seconds.

## Outcome

Ship a **Watch Widget HIG pack** (implement, not docs-only):

1. **Glance hierarchy** — primary value + kind/state dominate every accessory family; demote or remove redundant “Baby Care” chrome on rectangular.
2. **Accessible meaning** — VoiceOver summary for timer / last care / overdue; overdue not color-only on small families (symbol or short text cue).
3. **Honest empty** — use shared empty primary copy; keep placeholder/snapshot as realistic samples.
4. **Privacy** — `privacySensitive` on live timer and relative ages where accessory chrome supports redaction.
5. **Freshness unchanged** — App Group + coalesced reload + timeline policy remain the source of truth (no network in extension). Prefer wiring shared helpers over forking Watch-only rules.

## Metric

With a running nap/breast timer, VoiceOver announces kind + running meaning without opening the app. Idle overdue feed shows a non-color cue plus red on circular (and corner/inline as space allows). Empty mailbox face shows plain “No care yet” (or equivalent), not “·”. All four accessory families remain readable; Watch Widgets **BUILD SUCCEEDED**; focused unit tests cover display/a11y helpers already shared (extend only if Watch needs new strings).

## Sources (primary)

| Claim / topic | Primary source | Notes |
|---------------|----------------|-------|
| Shipped Watch widget UI | `MyBaby Watch Widgets/BabyCareWidgets.swift` | circular/corner/rect/inline; “·”; no a11y label |
| Display / overdue / empty / a11y helpers | `BabyCareShared/BabyCareComplicationDisplay.swift` | Phone already consumes; Watch lags |
| Timeline refresh | `BabyCareShared/BabyCareWidgetTimeline.swift` | timer horizon / next feed / 15m |
| App Group mailbox | `BabyCareShared/BabyCareStatusStore.swift` | DTO, no token |
| Kind reload list | `BabyCareShared/BabyCareWidgetKinds.swift` | `BabyCareComplication` |
| Phone HIG wiring pattern | `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift` | accessibilitySummary, overdue cue, empty, privacySensitive |
| Product shape | `README.md` “Add companions…” | face + Smart Stack; Care type |
| Prior Watch complication framing | `.my-docs/workflow/watch-complication-timer-status/01-idea.md` | timer + teal/red baseline |
| Prior Phone HIG framing | `.my-docs/workflow/phone-widget-hig/01-idea.md` | parallel pack; do not copy Phone families |
| Apple HIG Widgets | https://developer.apple.com/design/human-interface-guidelines/widgets | glanceable, relevant, personal |
| Apple WidgetKit | https://developer.apple.com/documentation/widgetkit | families, timeline, App Intent config |
| Creating a widget extension | https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension | placeholder / snapshot / timeline |
| Apple Accessibility | https://developer.apple.com/design/human-interface-guidelines/accessibility | not color-alone; labels |
| watchOS complications / WidgetKit | https://developer.apple.com/documentation/widgetkit/widgetfamily | accessory* families |

## Has UI

**yes** — Watch face complications + Smart Stack accessory surfaces only. No new in-app logging UI.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Keep care meaning identical to Phone/shared (`resolve` + teal/red). Improve layout, a11y, empty, overdue cue, privacy — do not invent a second status ruleset. Prefer shared helpers already shipped for Phone. No network from the extension. Do not add Home Screen–style systemSmall/medium on Watch.

## 80/20 UI (day-to-day)

### Main user goals

- Glance running care timer without opening the app
- See last care and whether it is still OK vs overdue
- Understand the face with VoiceOver / without relying on color alone
- Tap to jump into the matching care page when action is needed

### Vital few (high-impact ~20%)

- Primary value always readable (timer or relative last care)
- State cue (kind + in-range vs overdue) without color-only overdue on small families
- Clear empty state
- VoiceOver one-line summary

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Primary value — live timer or last-care age
- **Important info / action #2 (always visible):** Kind / state cue (icon or label; overdue not color-only)
- **Core action placement:** Compact accessory layouts; rectangular may keep one secondary line
- **Secondary actions:** Configuration Care type; tap deep link into app

### Top user journey to optimize

Raise wrist → see timer or last care + overdue meaning in &lt;2s → optionally tap into care page

### Sensible defaults

- Care type **Auto** (already default)
- Sample snapshot in gallery / empty mailbox read path unchanged at store layer
- Teal in-range / red overdue meaning unchanged

### Biggest usability risks first

1. Color-only overdue on circular/corner → missed at a glance / a11y fail
2. Empty “·” looks like a bug
3. Missing VoiceOver summary on wrist
4. Rectangular brand title crowding kind + value

## Non-goals

- New care types, Live Activities, interactive widget buttons, or logging from the complication
- Network / GraphQL / token reads from the widget extension
- Changing App Group DTO shape or timeline policy (unless a proven HIG bug requires a tiny tweak)
- Phone widget / Home Screen work (already in `phone-widget-hig`)
- Full Always On redesign beyond privacySensitive / system chrome tweaks
- Extra accessory families beyond the four already shipped

## Assumptions to attack

- Shared `accessibilitySummary` / `emptyPrimaryText` / `showsOverdueCue` are enough for Watch without new copy APIs
- Corner / inline can show a short overdue cue without breaking layout
- `privacySensitive` is meaningful on watchOS accessory faces the same way as Phone Lock Screen
- Demoting “Baby Care” on rectangular does not hurt gallery discoverability (configurationDisplayName remains)

## Success criteria

- [ ] All four accessory families: empty primary ≠ “·”; uses shared empty copy
- [ ] VoiceOver uses `accessibilitySummary` (or equivalent) on the entry view
- [ ] Overdue idle shows non-color cue on circular at minimum; corner/inline as space allows
- [ ] Rectangular: kind + primary dominate; brand title demoted or removed
- [ ] Timer / relative ages marked privacySensitive where applicable
- [ ] Watch Widgets build succeeds; unit coverage for any new Watch-facing strings (or reuse Phone-covered helpers)

## Open questions

1. Should rectangular keep a tiny product wordmark, or drop it entirely (Phone medium demoted title)?
2. For circular overdue: prefer SF Symbol badge, “!” / “Overdue” text, or icon swap — Design picks after layout spike.
3. Any Always On–specific QA device required before Gate C, or simulator + unit enough for this pack?
