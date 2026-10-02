# Idea: Widgets security + performance pack (Phone + Watch)

## Project shape (quick scan)

MyBaby ships **Phone Home Screen widgets** (`MyBaby Phone WidgetsExtension`) and **Watch complications / Smart Stack** (`MyBaby Watch Widgets`). Both read care status from App Group `group.vn.in4.MyBaby` via `BabyCareStatusStore` (status DTO only — no API tokens). Timeline refresh uses `BabyCareWidgetTimeline` + app-side `WidgetTimelineReloadCoalescer`; extensions do not call the network.

## Problem

Widgets already glance, but security and performance are not reviewed as one Widgets-focused pack:

- **Trust / privacy:** empty App Group falls back to **sample** care data (`sampleNextFeed`), which can look like real baby status. Lock Screen / accessory faces need consistent privacy redaction. Deep-link taps must stay on known care pages.
- **Secrets boundary:** App Group mailbox must stay status-only (no tokens). Widget entitlements/Info must stay minimal (no network / CloudKit in the extension).
- **Battery / WidgetKit budget:** reload coalescing exists, but timeline policy, dual-kind reloads, and decode cost need a pass against Apple WidgetKit guidance (lightweight timelines, honest freshness, avoid thrash).

Parents need widgets that are **honest, private, and cheap to refresh** — not a mini app and not a leaky mailbox.

## User / audience

Parents / co-caregivers who glance Phone Home Screen or Watch face / Lock Screen / Smart Stack between care logs — often one-handed, low light, holding a baby. They trust what the face shows.

## Outcome

Ship a **Widgets security + performance improvement pack** (implement, not docs-only) across Phone + Watch extensions and shared helpers:

1. **Honest empty** — no sample masquerading as live care when the mailbox is empty; clear empty / preview paths.
2. **Mailbox trust** — keep DTO status-only; harden forbidden-key checks / write path; confirm extensions never read Keychain tokens or hit the network.
3. **Privacy surfaces** — consistent `.privacySensitive()` / redacted behavior on accessory / Lock Screen primary care times (align Phone + Watch).
4. **Deep-link safety** — widget URLs only open known care pages (existing `BabyHomeDeepLink` contract).
5. **Refresh budget** — timeline `nextUpdate` + coalescer policy tuned to Apple WidgetKit practices; avoid needless dual-kind thrash where safe.
6. **Defer** interactive buttons, Live Activities, and app-wide ATS/token work already covered by `phone-security-perf` / `watch-security-perf`.

## Metric

With an empty App Group mailbox, Phone small widget and Watch circular complication show a clear empty face (not sample feed/nap). Unit tests prove DTO encoding never includes forbidden secret keys and empty→snapshot does not invent live care. Timeline next-update tests stay green for timer / next-feed / 15m idle. Phone WidgetsExtension + Watch Widgets **BUILD SUCCEEDED**.

## Sources (primary)

| Claim / topic | Primary source | Notes |
|---------------|----------------|-------|
| Phone widget UI / timeline / privacySensitive | `MyBaby Phone Widgets/MyBaby_Phone_Widgets.swift` | families, `.privacySensitive()`, App Group read |
| Watch widget UI / timeline | `MyBaby Watch Widgets/BabyCareWidgets.swift` | accessory families, privacySensitive |
| App Group mailbox DTO | `BabyCareShared/BabyCareStatusStore.swift` | `forbiddenKeys`, `snapshotForWidgets` → sample fallback |
| Timeline policy | `BabyCareShared/BabyCareWidgetTimeline.swift` | timer 15m / next feed / 15m idle |
| Reload coalesce | `BabyCareShared/WidgetTimelineReloadCoalescer.swift` | 750ms debounce; both kinds |
| Kind names | `BabyCareShared/BabyCareWidgetKinds.swift` | `BabyCarePhoneHome`, `BabyCareComplication` |
| Display / deep link page | `BabyCareShared/BabyCareComplicationDisplay.swift` | resolve mode + deepLinkPage |
| Deep link URL | `BabyCareShared/BabyHomePage.swift` (`BabyHomeDeepLink`) | `mybaby://home?page=…` |
| Persist from apps | `BabyCareShared/BabyHomeStatusModel.swift` | `persistStatusForWidgets` comment: never token |
| Widget entitlements | `Config/Widgets.entitlements` | App Group only |
| Extension Info | `Config/Widgets-Info.plist`, `Config/PhoneWidgets-Info.plist` | WidgetKit extension point only |
| Product shape | `README.md` M3 + companions | no network from widget |
| WidgetKit | https://developer.apple.com/documentation/widgetkit | timelines, configuration, reload |
| HIG Widgets | https://developer.apple.com/design/human-interface-guidelines/widgets | glanceable, relevant, personal |
| privacySensitive | https://developer.apple.com/documentation/swiftui/view/privacysensitive(_:) | Lock Screen / Always On redaction |

## Has UI

**yes** — widget faces (empty honesty, privacy redaction consistency). No new in-app screens.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** empty face copy; keep existing hierarchy from HIG packs; privacy redaction on primary times; no new chrome or interactive controls

## 80/20 UI (day-to-day)

### Main user goals

- Glance live timer or last care without opening the app
- Trust that the face is real (or clearly empty / preview)
- Tap to open the right care tab / page
- Keep Lock Screen / Watch face from leaking care times when device is locked / shared glance

### Vital few (high-impact ~20%)

- Honest empty vs sample (trust)
- Privacy-sensitive primary times on accessory / Lock Screen
- Stable, cheap refresh (still shows timer / overdue without thrash)
- Safe deep link into Feed / Sleep / Diaper / Pump / status

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** care kind + live timer or last-care age (or clear empty)
- **Important info / action #2 (always visible):** overdue / in-range cue (not color alone — already partly from HIG packs)
- **Core action placement:** glance hierarchy unchanged; tap whole widget
- **Secondary actions:** Care type edit (system Edit Widget / face Edit) stays secondary

### Top user journey to optimize

Home Screen / Watch face glance → (optional) edit Care type once → tap opens matching care page when action needed

### Sensible defaults

- Care type **Auto**
- Empty mailbox → empty face (not sample)
- Preview / gallery → labeled sample only when `context.isPreview`

### Biggest usability risks to fix first

1. Sample data shown as live when mailbox empty (false trust)
2. Privacy gap on any accessory primary line missing `.privacySensitive()`
3. Stale or thrashing face that drains battery or confuses freshness

## Non-goals

- Re-doing full Phone/Watch HIG visual packs (`phone-widget-hig`, `watch-widget-hig`)
- App Connect ATS / Keychain token hardening outside App Group boundary (already in app security-perf runs)
- Live Activities, interactive widget buttons, Control Center controls
- CloudKit / network inside widget extensions
- New widget kinds or new App Group IDs

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| Empty mailbox → sample is still OK for UX | No — treat as trust bug unless proven | Reproduce empty group on Simulator | Keep sample only for `isPreview` / placeholder |
| Extensions never import network clients | Yes for this pack | Grep widget targets for URLSession / GraphQL | Strip or exclude shared network types from extension |
| Coalescer 750ms + 15m policy is “good enough” | Unknown | Compare to WidgetKit timeline guidance + battery notes | Tune delay / nextUpdate / kind reload set |
| Dual-kind reload is required on every persist | Likely yes (shared mailbox) | Confirm both platforms share DTO | Keep both; document why |
| Prior HIG privacySensitive covers all faces | Unknown | Diff Phone vs Watch primary Text paths | Fill gaps only |

## What we should not build

- A second status store or dual DTOs
- Docs-only audit with no code changes
- Full UI redesign of small/medium/accessory layouts

## Success criteria

- [ ] Empty App Group → empty widget face (Phone + Watch); sample only for placeholder / preview
- [ ] Unit tests: forbidden DTO keys; empty snapshot honesty; timeline nextUpdate cases
- [ ] Accessory / Lock Screen primary care times use privacySensitive where care time is shown
- [ ] Widget targets still App Group–only entitlements; no network from extension code paths
- [ ] Coalescer + timeline policy documented and covered by tests; no reload thrash regression
- [ ] Phone WidgetsExtension + Watch Widgets build succeed

## Open questions

- Should empty face copy match HIG pack strings (“No care yet”) or stay minimal for circular?
- Prefer one shared empty-snapshot helper vs per-platform UI strings only?
- Any Watch-only complication families still missing privacySensitive after HIG pack?
