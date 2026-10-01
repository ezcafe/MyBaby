# Idea: Phone M3 — Home Screen widgets (App Group)

## Project shape (quick scan)

MyBaby Phone App (M1–M2) connects Offline or Cloud and logs care on bottom tabs Feed / Sleep / Diaper / Pump / Last care via shared `BabyHomeStatusModel`. Watch already ships WidgetKit complications that read App Group mailbox `group.vn.in4.MyBaby` (`BabyCareStatusDTO`). Phone Widgets target exists but is still the Xcode emoji/time stub plus unused ControlWidget and Live Activity templates.

## Problem

After logging care on iPhone, caregivers cannot glance at Home Screen status. Watch face companions already show live timer or last-care color from the App Group; Phone has no equivalent. The stub widget shows fake emoji/time and does not read care status. `persistStatusForWidgets` today reloads only Watch kind `BabyCareComplication`, so even a correct Phone widget would stay stale until policy refresh.

## User / audience

- Parents / co-caregivers with iPhone on the lock/home screen who need a quick glance between logs
- Same Offline or Cloud users as M1–M2 (widget is read-only status, not a second Connect path)

## Outcome

**M3 only:**

1. Replace Phone Widgets stub with a real **Baby Care** Home Screen widget that reads the same App Group status mailbox as Watch (no network in the extension).
2. Show **running care timer** with system live date style when a timer is active; when idle, show **last care** with teal (in range) / red (out of range) — same meaning as Watch companions.
3. Support **Care type** config: Auto | Feed | Sleep | Diaper | Pump (default Auto), matching Watch `BabyCareComplicationIntent`.
4. Ship useful iOS families at least **systemSmall** and **systemMedium** (Design may add large if cheap).
5. Tap opens Phone app care page via existing deep link (`mybaby://home?page=…`).
6. Phone app persist path reloads the **Phone** widget kind (and keep Watch reload for shared model).
7. Remove or leave disabled the stub ControlWidget / Live Activity from the bundle so the gallery is not polluted (prefer remove from bundle in M3).

## Metric

With Phone care home running a breast or nap timer, add widget → Home Screen shows a live counting timer within one second of wall time (system `.timer`). Stop timer → idle last-care teal or red. Empty App Group → safe sample/placeholder (no crash, no token). Unit tests prove DTO load, display priority, color band, and forbidden keys; Phone widget scheme builds.

## Sources (primary)

| Claim / topic | Primary source | Notes |
|---------------|----------------|-------|
| App Group mailbox | `BabyCareShared/BabyCareStatusStore.swift` | `group.vn.in4.MyBaby`, DTO v1, no token |
| Timeline policy | `BabyCareShared/BabyCareWidgetTimeline.swift` | Long horizon while timer; else next-feed / 15m |
| Persist + reload | `BabyCareShared/BabyHomeStatusModel.swift` `persistStatusForWidgets` | Today reloads `BabyCareComplication` only |
| Watch widget UX | `MyBaby Watch Widgets/BabyCareWidgets.swift` | Care type intent, families, teal/red |
| Prior design | `.my-docs/workflow/watch-complication-timer-status/` | App Group + `.timer` pattern locked |
| Phone stub | `MyBaby Phone Widgets/MyBaby_Phone_Widgets*.swift` | Replace |
| Entitlements | `Config/PhoneApp.entitlements`, `Config/Widgets.entitlements` | App Group already present |
| Deep links | `BabyCareShared` deep link + README | `mybaby://home?page=…` |
| WidgetKit (platform) | [Creating a widget extension](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension) | Home Screen families; no network requirement for this design |
| Program ladder | `.my-docs/workflow/phone-app-parity/00-run.md` | M3 after M2 |

## Has UI

**yes** — iOS Home Screen widget surfaces (small/medium; optional large); configuration for Care type; no new in-app logging UI.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Match Watch companion meaning (timer vs last care + color). Adapt layout to systemSmall/Medium (not accessory circular). Reuse shared display helpers where they exist; extract only if needed. Teal = `BabyTokens.accent`; red = danger/overdue. Do not invent a second status ruleset.

## 80/20 UI (day-to-day)

### Main user goals

- Glance whether a care timer is running without opening the app
- See how long since last care when idle
- Tell if last care is still OK (teal) or overdue (red)
- Tap to jump into the matching care tab when action is needed

### Vital few (high-impact ~20%)

- Live timer when a relevant care timer is running
- Last-care time + in/out-of-range color when idle
- Care type Auto default + optional fixed Feed/Sleep/Diaper/Pump

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Primary value — live `.timer` while running; last-care relative/clock when idle
- **Important info / action #2 (always visible):** State cue — care kind label/icon while running; teal vs red when idle
- **Core action placement:** Compact Home Screen layouts; medium may add one secondary line (e.g. next feed when idle)
- **Secondary:** Care type picker in widget Edit (not on the face); full logging stays in Phone app

### Top user journey to optimize

Log or start timer in Phone app → leave to Home Screen → glance widget → see live timer or last-care color → tap only if need to log again

### Sensible defaults

- Care type **Auto** (same priority as Watch: open nap → breast → pump → else latest care)
- Families: **systemSmall** + **systemMedium** required for M3; large optional if reuse is cheap
- Live digits via `Text(startedAt, style: .timer)`; no 1 Hz TimelineView
- Empty mailbox → sample/placeholder snapshot (existing store fallback pattern)
- No network from widget extension

### Biggest usability risks to fix first

- Stub emoji widget ships and confuses users
- Status writes but Phone widget never reloads (wrong kind)
- Stale “next feed” while breast/pump timer runs
- Red/teal hard to read on small/medium
- Tap opens wrong page vs Care type / Auto resolution

## Non-goals (M3)

- New GraphQL / network from the widget
- Live Activities / Dynamic Island (defer; remove stub from bundle)
- Control Center ControlWidget (remove stub from bundle)
- Lock Screen accessory widgets beyond what comes free with shared kind (Design may note later)
- M4 activities / insights / growth / settings depth
- Changing care logging rules or Connect
- Putting API token or pairing code in App Group
- watchOS complication redesign

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| Phone + Widgets share App Group and can read DTO written by Phone app | Yes | Entitlements + unit suite round-trip | Fix signing/group; block ship |
| Existing DTO + Watch display rules are enough for Phone glance | Prefer yes | Map Watch display helpers to iOS families | Extract shared mapper; thin Phone views |
| `Text(..., .timer)` works on iOS systemSmall/Medium | Yes for live feel | Spike in Analyze | Fall back to ~1 min rebuilds |
| Reloading both Watch + Phone kinds from shared model is enough | Yes | Add Phone kind string to persist | Document dual reload |
| Caregivers want Auto + type filter like Watch | Prefer yes | Mirror Watch intent | Ship Auto-only if config costly |

## Success criteria

- [ ] Stub emoji / Control / Live Activity no longer in Phone widget gallery bundle
- [ ] systemSmall + systemMedium show live timer or last-care + color from App Group
- [ ] Care type Auto | Feed | Sleep | Diaper | Pump works
- [ ] Tap deep-links to matching Phone care page
- [ ] `persistStatusForWidgets` reloads Phone widget kind (and Watch)
- [ ] forbiddenKeys / no-token tests still pass; empty suite safe
- [ ] Unit tests for Phone widget display mapping / reload kind; Phone Widgets (+ App) build

## Open questions

1. Include **systemLarge** in M3 or defer? Prefer: include if same provider/views scale; else small+medium only.
2. Share SwiftUI views with Watch accessory widgets vs Phone-only layouts that call shared pure helpers? Prefer: shared pure display model + Phone-specific SwiftUI.
3. Exact Phone widget `kind` string (new constant, not `BabyCareComplication`)? Prefer: new kind e.g. `BabyCarePhoneHome` + dual reload.

None blocking for Gate A — defaults above are enough for day-to-day review.
