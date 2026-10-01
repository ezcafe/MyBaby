# Analysis: watch-widget-hig

## Overall deep dive

### What is this?

A HIG / WidgetKit improvement pack for the shipped Watch Baby Care complications (face + Smart Stack): accessibility, overdue meaning beyond color, empty copy, rectangular hierarchy, privacySensitive — wiring shared helpers Phone already uses.

### Why do we need this?

Parents raise the wrist for a 1–2s glance. Today VoiceOver is missing on Watch, overdue on circular/corner/inline is mostly color, empty still shows “·”, and rectangular spends a line on “Baby Care”. Shared helpers already exist; Watch UI lags Phone.

### How to do this?

Wire `BabyCareComplicationDisplay` helpers into `BabyCareWidgets.swift` layouts; keep App Group / timeline / deep links / Care type intent. Other ways: Watch-only string forks (worse drift); new families or interactive buttons (out of scope). Best practice: reuse Phone’s a11y/empty/overdue/privacySensitive patterns on accessory families.

## Solution pieces (≤5)

### 1. Accessibility summary on entry view

- **What:** Apply shared `accessibilitySummary` on Watch entry view.
- **Why:** Gate A # understanding; Phone already covered.
- **How:** `.accessibilityElement(children: .combine)` + `.accessibilityLabel(display.accessibilitySummary)`. Alt: family-local strings — reject (drift).

### 2. Non-color overdue cue on small families

- **What:** Text/symbol when `showsOverdueCue` on circular (required); corner/inline as space allows; rectangular already has “X overdue”.
- **Why:** HIG — not color alone.
- **How:** Mirror Phone small: icon + overdue word/symbol when red idle. Design picks cue shape (Open Q2).

### 3. Empty / primary copy

- **What:** Replace “·” with `emptyPrimaryText` in circular/corner/wide/inline empty branches.
- **Why:** Cryptic empty looks broken; shared constant + tests exist.
- **How:** View empty branches only; keep nil-mailbox → sample at store.

### 4. Rectangular hierarchy + privacy

- **What:** Demote/remove “Baby Care” title; `privacySensitive` on timer/relative ages.
- **Why:** Glance hierarchy; Always On / privacy HIG.
- **How:** Kind + primary dominate; secondary overdue/sentence stays; mark time Texts like Phone.

### 5. Accent / system chrome (optional polish)

- **What:** Prefer accessory-friendly foreground (keep teal/red meaning) without fighting Always On.
- **Why:** Hard hex may be OK if meaning preserved; don’t expand scope.
- **How:** Keep current accent unless Build finds Always On contrast fail — prefer Enhancement, not Critical.

## Spike notes

None — code + Phone parallel sufficient. Shared a11y tests already green in Watch AppTests.

## Reusable patterns

- Shared `resolve` + `accessibilitySummary` / `emptyPrimaryText` / `showsOverdueCue`
- AppIntentConfiguration + recommendations
- `.timer` Text for running care
- Deep link `BabyHomeDeepLink.url(page:)`
- Phone widget privacySensitive + overdue cue layout

## System shape candidates

- **A (recommended):** Wire shared helpers into Watch views only; no new kinds; no display API changes unless a tiny cue helper is needed.
- **B:** Add new shared overdueSymbol API + Watch — only if view needs it; prefer reuse first.
- **C:** Redesign all families / add logging buttons — reject (non-goal).

## Design tree (frontier)

1. **N1 Rectangular title** — drop entirely vs tiny demoted wordmark
2. **N2 Circular overdue cue** — SF Symbol badge vs short “!” / “Overdue” text vs icon swap
3. **N3 Accent polish** — keep hex teal/red vs tweak system styles (likely defer Enhancement)

## Settled (from idea / Gate A)

- Has UI yes; Has API no; Has DB no
- No network; no interactive log; no Live Activities; no new families
- #1 primary value; #2 kind/range cue
- Care rules / timeline / App Group unchanged
- Prefer shared helpers already unit-tested

## Enough to design?

**yes** — after Grill settles N1–N3.
