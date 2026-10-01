# Idea: iOS HIG UI pack (MyBaby Phone)

## Problem

MyBaby Phone App already connects (Offline | Cloud), logs care on five bottom tabs, and opens Settings — but the chrome still feels partly **Watch-ported** and partly **developer-facing**, not iPhone-native. Connect leads with “API server,” custom Offline/Cloud chips, and an ad-hoc scroll form. Care pages reuse shared Watch-tuned tokens (caption2 tips, tight padding, section headers that repeat the tab name). Parents on iPhone expect system tab bars, Form/List connect, clear labels, Dynamic Type–friendly controls, and phone-scale layout — without changing care rules.

## User / audience

Parents and co-caregivers logging feed / sleep / diaper / pump on **iPhone**, often one-handed, sometimes at night, after opening from a Home Screen widget or cold start.

## Outcome

A prioritized **iOS HIG improvement pack** for Phone shell + care chrome: Connect, Tab home, Settings, and phone-facing shared care layout. The app feels like a normal iOS companion (tab bar, Form/List, system buttons/materials, clear copy) while keeping Offline/Cloud behavior and quick-care rules. Design lists concrete gaps vs Apple HIG and ships the vital few fixes first.

## Metric

A caregiver can: open Connect and start Offline (or Cloud + code) without reading API jargon; switch care tabs with clear labels; complete the top job on the current tab (e.g. start nap or log wet) with phone-scale controls; open Settings and Leave when needed — all with Dynamic Type and VoiceOver still usable on the primary path.

## Has UI

**yes**

## Copy/token-only?

**no** — layout, chrome, copy, and shared phone presentation may change; care business rules stay.

## UI notes for Design

- Prefer **system** iOS patterns: `TabView` tab items, `Form`/`List` Connect, `Picker` segmented Offline|Cloud, `.borderedProminent` / destructive roles, sheets with nav titles.
- Phone may need **platform-aware** sizing in shared care UI (do not break Watch) — settle in Analyze/Grill.
- Widgets (M3) are out of scope unless a gap blocks the primary open-from-widget → tab journey.

## 80/20 UI (day-to-day)

### Main user goals

- Start Offline (or Cloud pair) once and get to care fast
- Log the care job on the current tab in one or two taps
- See fail + Retry without hunting
- Leave / see session mode rarely from Settings

### Vital few (high-impact ~20%)

- Connect: parent copy + Offline default primary CTA; Cloud code path clear
- Tab bar: clear labels; primary care actions phone-scale and reachable
- Fail → Retry always reachable
- Settings Leave with clear mode label

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Primary care control(s) for the selected tab (e.g. Breast L/R, Nap, Diaper tiles)
- **Important info / action #2 (always visible):** Tab identity (tab bar) + Offline/Cloud primary Connect CTA when not connected
- **Core action placement:** Care chips large enough for thumb on phone; Connect primary button prominent; secondary help behind “Need help?”
- **Secondary actions:** Bottle/Pump amount sheets; Advanced paste URL & token; Settings gear; tips / recovery footers

### Top user journey to optimize

Cold start or widget tap → (Connect if needed: Offline Start / Cloud code) → care tab → tap primary chip → Done / timer → (Retry if Failed)

### Sensible defaults

- Connect defaults to **Offline** (existing)
- Landing care tab remains **Feed** (existing)
- Tab order: Feed → Sleep → Diaper → Pump → Last care (existing)
- Teal accent kept as brand tint where system tint is used

### Biggest usability risks to fix first

- Connect sounds like a developer console (“API server”) — parents bounce or hesitate
- Care UI feels empty or tiny on phone (Watch tokens) — hard to tap / hard to read at night
- Tab label “Last” is unclear vs “Status” / “Last care”
- Shared layout changes must not regress Watch

## Non-goals

- New GraphQL endpoints, pairing API, or CloudKit schema
- Changing quick-care side-effect rules
- Redesigning Watch HIG pack or web Baby home
- New care types, multi-baby, or Insights on phone
- Full widget visual redesign (M3 already shipping)

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| Phone can adapt shared CarePages/CareControls without forking all of Watch | Prefer yes | Analyze `#if os` / size-class hooks | Thin phone wrappers or duplicate phone-only pages |
| Form + segmented Offline/Cloud is enough for Connect | Prefer yes | Gate A day-to-day | Keep custom chips if Form feels worse |
| Tab count of 5 is acceptable for iOS HIG | Prefer yes | HIG tab-bars + Gate A | Collapse Last care into Settings / More |
| No API/DB changes needed for UI pack | Prefer yes | Analyze | If copy-only tokens need server — out of scope |

## What we should not build

- A sixth tab or hamburger IA
- Decorative gradients with no meaning
- Replacing TabView with swipe-only pages on phone

## Success criteria

- [ ] Connect uses parent-facing title/copy; Offline|Cloud selection is system-like; primary CTA obvious; help/advanced secondary
- [ ] Tab items have clear labels (esp. Last care / Status); SF Symbols remain meaningful
- [ ] Care pages on phone use phone-appropriate type size, spacing, and hit targets; Watch unchanged or explicitly verified
- [ ] Fail + Retry remain reachable from home chrome
- [ ] Settings stays List + Done; Leave destructive and understandable
- [ ] Dynamic Type / VoiceOver checked on Connect + one care tab primary path
- [ ] Design documents HIG gaps → prioritized tasks; Build ships vital few

## Open questions

- Rename tab “Last” → “Status” vs “Last care” (truncation risk)? Prefer short clear label settled in Design.
- How far to adapt shared care UI for phone vs phone-only wrappers — settle in Analyze/Grill.
- Confirm Leave needs a confirmation alert (HIG destructive) — prefer yes if easy.

## Sources (primary)

- `README.md` — Phone M1–M3 product shape
- `MyBaby Phone App/PhoneConnectView.swift` — Connect UI
- `MyBaby Phone App/PhoneHomeView.swift` — TabView + toolbar + Settings sheet
- `MyBaby Phone App/PhoneContentView.swift` — auth gate / NavigationStack
- `MyBaby Phone App/PhoneSettingsSheet.swift` — Settings List
- `BabyCareShared/CarePages.swift`, `CareControls.swift`, `BabyTokens.swift` — shared care chrome
- Prior pattern: `.my-docs/workflow/watch-hig-ui/01-idea.md` — Watch HIG pack framing
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/) — iOS design authority
- [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars) — tab count, labels, clarity
- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons) — prominent / destructive roles
- [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets) — modal presentation
- [Typography](https://developer.apple.com/design/human-interface-guidelines/typography) — Dynamic Type
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) — VoiceOver / hit targets
