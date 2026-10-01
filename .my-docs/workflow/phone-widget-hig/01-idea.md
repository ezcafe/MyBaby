# Idea: Phone Widget HIG + best-practices pack

## Project shape (quick scan)

MyBaby Phone App embeds **MyBaby Phone WidgetsExtension**. Kind `BabyCarePhoneHome` shows Care type Auto | Feed | Sleep | Diaper | Pump on **systemSmall** and **systemMedium**, reading App Group `group.vn.in4.MyBaby` (no network). Live `.timer` when a care timer runs; idle last-care with teal/red; tap deep-links into care tabs. Shared display/timeline helpers live in `BabyCareShared/`.

## Problem

The Phone widget works for basic glance, but it does not fully follow Apple Widgets HIG / WidgetKit practices caregivers expect on Home Screen:

- VoiceOver has no clear combined label (unlike Phone Connect / care chips).
- Overdue relies heavily on **color alone** (red vs teal).
- Empty / no-care face shows cryptic “·”.
- Layout uses very tight padding and a medium brand title that steals glance space.
- No Lock Screen / StandBy accessory families (Watch already ships accessory rectangular).
- Accessibility / Dynamic Type and privacy-redacted paths are not designed for the widget face.

Parents need a glanceable, accessible, Apple-shaped widget — not a second mini app.

## User / audience

Parents / co-caregivers who already use MyBaby Phone care home and glance the Home Screen (and optionally Lock Screen) between logs — often one-handed, low light, holding a baby.

## Outcome

Ship a **Phone Widget HIG pack** (implement, not docs-only):

1. **Glance hierarchy** — primary value + state cue dominate small/medium; cut redundant chrome that fights Apple widget margins.
2. **Accessible meaning** — VoiceOver summary for timer / last care / overdue; overdue not color-only (icon/text cue).
3. **Honest empty / preview** — clear empty copy; placeholder/preview stay realistic samples.
4. **Families** — keep small+medium solid; add Lock Screen / relevant accessory family **if** cheap reuse of Watch rectangular meaning; defer interactive buttons and Live Activities.
5. **Freshness unchanged** — App Group + coalesced reload + timeline policy remain the source of truth (no network in extension).

## Metric

With a running nap/breast timer, VoiceOver announces kind + live timer meaning without opening the app. Idle overdue feed shows a non-color cue plus red. Empty mailbox shows plain “No care yet” (or equivalent), not “·”. Small/medium layouts remain readable at default Dynamic Type. Phone WidgetsExtension **BUILD SUCCEEDED**; focused unit tests cover display/a11y string helpers.

## Sources (primary)

| Claim / topic | Primary source | Notes |
|---------------|----------------|-------|
| Shipped Phone widget UI | `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift`, `AppIntent.swift`, `MyBaby_Phone_WidgetsBundle.swift` | small/medium, timer, deep link |
| Display / color / deep link | `BabyCareShared/BabyCareComplicationDisplay.swift` | shared with Watch |
| Timeline refresh | `BabyCareShared/BabyCareWidgetTimeline.swift` | timer horizon / next feed / 15m |
| App Group mailbox | `BabyCareShared/BabyCareStatusStore.swift` | DTO, no token |
| Kind reload list | `BabyCareShared/BabyCareWidgetKinds.swift` | `BabyCarePhoneHome` |
| Watch accessory pattern | `MyBaby Watch Widgets/BabyCareWidgets.swift` | accessoryRectangular |
| Product shape | `README.md` M3 section | families, no network |
| Phone in-app a11y pattern | `MyBaby Phone App/PhoneConnectView.swift`, `CareControls.swift` | labels to mirror |
| Apple HIG Widgets | https://developer.apple.com/design/human-interface-guidelines/widgets | glanceable, relevant, personal |
| Apple WidgetKit | https://developer.apple.com/documentation/widgetkit | families, timeline, App Intent config |
| Apple Accessibility | https://developer.apple.com/design/human-interface-guidelines/accessibility | not color-alone; labels |
| Creating a widget extension | https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension | placeholder / snapshot / timeline |

## Has UI

**yes** — Home Screen (and optional Lock Screen) widget surfaces only. No new in-app logging UI.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Keep care meaning identical to Watch (timer vs last care + teal/red). Improve layout, a11y, empty, optional accessory — do not invent a second status ruleset. Prefer shared helpers over Phone-only forks. No network from the extension.

## 80/20 UI (day-to-day)

### Main user goals

- Glance running care timer without opening the app
- See last care and whether it is still OK vs overdue
- Understand the face with VoiceOver / without relying on color alone
- Tap to jump into the matching care tab when action is needed

### Vital few (high-impact ~20%)

- Primary value always readable (timer or relative last care)
- State cue (kind + in-range vs overdue) without color-only overdue
- Clear empty state
- VoiceOver one-line summary

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Primary value — live `.timer` while running; last-care relative when idle
- **Important info / action #2 (always visible):** Kind + range cue (label/icon; overdue text or symbol, not color alone)
- **Core action placement:** Compact Home Screen layouts; medium may keep **one** secondary line
- **Secondary:** Care type Edit picker; app brand title if space allows; Lock Screen family if shipped

### Top user journey to optimize

Log / start timer in Phone → Home Screen glance → hear/see timer or overdue cue → tap only to log again

### Sensible defaults

- Care type **Auto**
- Families: **systemSmall** + **systemMedium** required; accessory / large only if Design proves cheap
- Live digits via `Text(..., style: .timer)`
- Empty → plain empty copy (not sample pretending to be live); gallery placeholder/preview may use samples
- No network from widget

### Biggest usability risks to fix first

- Cryptic “·” empty face looks broken
- Color-only overdue fails accessibility and low-light clarity
- Missing VoiceOver summary on a glance surface
- Clutter (brand title + duplicate labels) hiding the timer at a glance
- Shipping Lock Screen without privacy/redacted thought

## Non-goals

- Interactive widget buttons that log care (Start nap / Feed chips on the face)
- Live Activities / Dynamic Island
- Network fetch from the widget extension
- Changing care business rules or App Group DTO schema (unless a tiny additive a11y helper string)
- Full Phone in-app HIG (already `phone-hig-ui`) or security/perf pack (`phone-security-perf`)
- Watch widget redesign (reuse patterns only)

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| Shared display helpers can expose a11y / overdue text without forking Phone UI | Prefer yes | Analyze `BabyCareComplicationDisplay` | Phone-only string helper beside views |
| Accessory Lock Screen can reuse Watch rectangular meaning cheaply | Open | Skim Watch accessory layout vs Phone entitlements | Defer accessory; Home Screen pack only |
| Empty mailbox is distinguishable from sample preview | Yes | Read `snapshotForWidgets` + placeholder paths | Explicit empty flag or nil handling in Design |
| Coalesced reload already enough for freshness | Prefer yes | Read `WidgetTimelineReloadCoalescer` | Timeline-only tweaks if stale remains |

## Success criteria

- [ ] VoiceOver announces kind + timer/last-care/overdue meaning on small and medium
- [ ] Overdue has a non-color cue (text and/or SF Symbol) in addition to danger color
- [ ] Empty live face uses clear copy (no lone “·”)
- [ ] Small/medium hierarchy matches #1/#2; padding/margins follow system widget chrome
- [ ] Optional accessory family either ships with privacy-safe copy or is explicitly deferred in Design
- [ ] Phone WidgetsExtension builds; unit tests cover new display/a11y helpers
- [ ] No tokens in App Group; no network from extension

## Open questions

1. Ship **Lock Screen / accessory** in this pack, or Home Screen-only first?
2. Add **systemLarge** with richer secondary status, or keep small+medium only?
3. Prefer shared `BabyCareComplicationDisplay` a11y API vs Phone-widget-local strings?
