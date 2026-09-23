# Analysis: Watch Baby Care multipage home + companions

**Size:** Prefer bullets. ≤5 solution pieces. Spike ≤5 rows. Stay within artifact size caps.
**Updated:** 2026-09-23
**Has API recommendation:** no — UI-first sample model + auth stub; GraphQL client later (contract exists in my-apps `BABY_API.md` but not implemented this pass)
**Has DB recommendation:** no — in-memory / App Group sample status only; no schema/migrations

## Deep dive (required)

### Overall

#### What is this?
A watchOS 10+ SwiftUI companion: multipage `BabyHomeView` (swipe) replicating web home care jobs, plus WidgetKit complications and Smart Stack widgets driven by a shared `BabyHomeStatusModel`.

#### Why do we need this?
Parents log care in seconds at night on the wrist and need glance status on the face without opening the phone or a dense scroll of every job.

#### How to do this?
- Replace Hello World with page `TabView`: **Feed+Bottle → Sleep → Diaper → Pump → Last care**.
- Shared status model + sample data for app and widgets; auth stub gate.
- Widget extension for complications + accessory/small/medium.
- **Other ways:** Keep web-like single vertical scroll (rejected at Gate A2). Live GraphQL from day one (defer — UI-first). Separate app per care type (overkill).
- **Best practices:** Apple `TabView` + `.tabViewStyle(.page)`; App Group / shared framework for widget data; deep links via `onOpenURL`; haptics `WKInterfaceDevice`; teal tokens from concept; mirror web quick-care semantics when wiring API later (`BABY_API.md`).

### Solution pieces

#### 1. Multipage BabyHomeView

##### What is this?
Five pages with three-slot chrome; page 1 stacks Feed (Breast L/R) then Bottle (ml).

##### Why do we need this?
One-thumb logging; swipe matches approved Gate A2 IA.

##### How to do this?
- Approach: `TabView(selection:)` + page style; per-page views; `ScrollView` inside Feed+Bottle if needed; page dots via `IndexViewStyle`.
- Other ways: `NavigationSplit` / vertical List of all jobs (rejected).
- Best practices: Large hit targets; one footer owner (pending > fail > tip); SF Symbols or simple care icons.

#### 2. Shared BabyHomeStatusModel

##### What is this?
Observable status: next feed, open nap, overdue, last-care lines, chip presets, timer running state.

##### Why do we need this?
App and companions must show the same primary signal.

##### How to do this?
- Approach: `ObservableObject` / `@Observable` model + `BabyHomeStatusSamples` for previews; App Group `UserDefaults` or shared package later for widgets.
- Other ways: Duplicate mock data per target (drifts — avoid).
- Best practices: Single source of truth; timeline provider reads same snapshot.

#### 3. WidgetKit companions

##### What is this?
Complications (circular/corner, rectangular/modular, inline) + Smart Stack small/medium.

##### Why do we need this?
Glance without opening app; success criterion for face/stack.

##### How to do this?
- Approach: Widget Extension target; priority: open nap → overdue → next feed → last care; refresh ~1 min while napping / at due.
- Other ways: ClockKit-only legacy (prefer WidgetKit on watchOS 10+).
- Best practices: Timeline entries; deep-link URLs; teal tint; always-on friendly contrast.

#### 4. Auth stub

##### What is this?
Connect iPhone / API token gate UI only.

##### Why do we need this?
Real Bearer `mny_…` belongs on phone pairing later; do not invent Watch cookies.

##### How to do this?
- Approach: Simple gate view; bypass for previews/sample mode.
- Other ways: Full Keychain + GraphQL now (out of UI-first scope).
- Best practices: Align with `BABY_API.md` Bearer when implemented.

#### 5. Deep links + haptics

##### What is this?
`mybaby://home?page=feed|sleep|diaper|pump|status`; haptics on save/timer.

##### Why do we need this?
Complication tap must land on the right page; feedback at 3AM.

##### How to do this?
- Approach: Parse URL → set `TabView` selection; `play(.success)` / `.click`.
- Other ways: Always open page 0 (fails success criteria).
- Best practices: Stable page IDs matching widget intents.

## What exists today

Greenfield Watch shell: `ContentView` Hello World, `MyBabyApp` `WindowGroup`, empty tests. No WidgetKit. Care contract: `/Users/ptquang86/ws/my-apps/docs/BABY_API.md` (`babyHomeQuickStatus`, `babyQuickCare`). Web IA: `my-apps/components/baby-home.tsx`.

## Dependencies

- New Widget Extension (+ shared sources or framework) in Xcode project
- Info.plist URL scheme
- App Group entitlement if widgets share live status (sample-only OK for MVP without Group)

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `MyBaby Watch App/ContentView.swift` | Replace with home shell |
| `MyBaby Watch App/MyBabyApp.swift` | Deep link + root |
| `/Users/ptquang86/ws/my-apps/docs/BABY_API.md` | Future API; enums/actions |
| `my-apps/components/baby-home.tsx` | Section chrome + copy tone |
| `.my-docs/workflow/watch-baby-care-home/01b-ui-concept.md` | Locked IA |

## Reusable patterns (prefer in Design)

| Pattern / name | Where it lives | Why Design should reuse it |
|----------------|----------------|----------------------------|
| Page TabView | Apple HIG / watchOS | Approved multipage nav |
| Three-slot care chrome | web `baby-home.tsx` | Header / controls / one footer |
| Timeline + priority signal | WidgetKit | Companions |
| Quick-care kinds | `BABY_API.md` | Future write mapping |

## System shape candidates (prefer in Design)

| Shape / concept | Where it lives | Why Design should teach it |
|-----------------|----------------|----------------------------|
| Watch app + Widget extension + shared model | Apple multi-target | Boundaries for status + UI |
| UI-first sample → GraphQL later | `BABY_API.md` | No fake cookie auth |

## Constraints and risks

- Feed+Bottle on one page may need Crown scroll — keep chips large
- One footer slot when both Feed and Bottle have pending — pick owner (web pending order)
- Widget without App Group only sees bundled sample until Group added
- Do not reorder pages vs locked Gate A2

## Settled decisions (do not relitigate)

- Multipage swipe (not vertical all-jobs list)
- Feed+Bottle combined page 1
- Last care = page 5 (Decision 1 Option 1)
- Page order: Feed+Bottle → Sleep → Diaper → Pump → Last care
- UI-first sample model; auth stub; Has API no; Has DB no
- Teal clean-minimal tokens; companions glance-only

## Open questions

- Exact bottle/pump ml chip list — use web defaults from `buildBabyBottleChipMls` / common snaps (e.g. 90/120/150…) in Design
- App Group now vs sample-only widgets until API — recommend sample + shared Swift files in both targets for MVP

## Enough to design?

yes — Gate A2 approved; IA locked; skim + API doc sufficient for UI-first Design.
