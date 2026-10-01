# Analysis: phone-widget-hig

## Overall deep dive

### What is this?

A HIG / WidgetKit improvement pack for the shipped Phone Baby Care Home Screen widget: accessibility, overdue meaning, empty copy, layout hierarchy — optional Lock Screen later.

### Why do we need this?

Parents glance between logs. Today VoiceOver is weak, overdue is mostly color, empty shows “·”, and medium spends space on a brand title. Apple Widgets HIG expects glanceable, accessible, personal widgets.

### How to do this?

Improve shared display helpers + Phone widget views; keep App Group / timeline / deep links. Other ways: Phone-only string forks (worse drift); full redesign / interactive buttons (out of scope). Best practice: shared `BabyCareComplicationDisplay` + system fonts/margins + VoiceOver labels; defer accessory until Home pack is solid.

## Solution pieces (≤5)

### 1. Accessibility summary string

- **What:** One VoiceOver label from display mode (kind + timer/relative + overdue).
- **Why:** Widget is glance-first; VO must work without opening the app.
- **How:** Add `accessibilitySummary(now:)` (or similar) on `BabyCareComplicationDisplay`; apply `.accessibilityElement(children: .combine)` + label on Phone entry view. Alt: view-local strings — worse for Watch reuse.

### 2. Non-color overdue cue

- **What:** Text or SF Symbol (“Overdue”) when `color == .red` idle.
- **Why:** HIG accessibility — do not rely on color alone.
- **How:** Small layout: keep icon + add overdue word when red; medium already has secondary “X overdue” — ensure small gets a cue too.

### 3. Empty / primary copy

- **What:** Replace lone “·” with “No care yet” (or kind-specific empty); keep gallery placeholder as sample.
- **Why:** Cryptic empty looks broken.
- **How:** View primaryValue empty branch; note `snapshotForWidgets` still samples when mailbox nil — live empty is mostly fixed care with no events (`mode == .empty`).

### 4. Layout / margins hierarchy

- **What:** Drop or demote medium “Baby Care” title; use system content margins instead of tiny `padding(4)`.
- **Why:** Glance hierarchy; Apple widget chrome already brands the widget.
- **How:** Restructure small/medium stacks; prefer `@Environment(\.widgetContentMargins)` / less manual padding.

### 5. Families scope

- **What:** Keep small+medium; Lock Screen accessory / systemLarge optional.
- **Why:** Watch already has accessory; Phone Lock Screen adds privacy surface.
- **How:** Design Decision — recommend Home-only pack first.

## Spike notes

None — code read sufficient.

## Reusable patterns

- Shared display resolve + relative formatters
- AppIntentConfiguration + recommendations
- `.timer` Text for running care
- Deep link `BabyHomeDeepLink.url(page:)`
- Watch rectangular secondary “X overdue” line

## System shape candidates

- **A (recommended):** Shared a11y + overdue/empty helpers → Phone layouts only change; no new kinds.
- **B:** Phone + Lock Screen accessoryRectangular in same pack.
- **C:** Interactive widget buttons — reject (non-goal).

## Design tree (frontier)

1. **N1 Families scope** — Home-only vs Home+Lock Screen vs +Large
2. **N2 A11y API home** — shared display vs Phone-local
3. **N3 Empty vs sample** — change live empty copy only vs also change nil-mailbox sample fallback (likely no — gallery needs samples)

## Settled (from idea / Gate A)

- Has UI yes; Has API no; Has DB no
- No network; no interactive log; no Live Activities
- #1 primary value; #2 kind/range cue
- Care rules unchanged

## Enough to design?

**yes** — after Grill settles N1–N3.
