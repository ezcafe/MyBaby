# Analyze: phone-m3-widgets

## Overall deep dive

1. **What is this?** iOS Home Screen widgets that glance Baby Care status (live timer or last-care + color) from the App Group mailbox already written by Phone/Watch care models.
2. **Why do we need this?** After M2, caregivers log on iPhone but cannot glance status on the Home Screen; Watch already has companions. Stub emoji widgets are useless and confusing.
3. **How to do this?** Replace Phone Widgets stub with AppIntentConfiguration widgets that load `BabyCareStatusStore`, resolve via `BabyCareComplicationDisplay`, render systemSmall/Medium with `.timer` / teal-red, deep-link, and dual-reload kinds from `persistStatusForWidgets`. Alternatives: Live Activity only (worse for glance permanence); network from widget (forbidden + fragile). Best practice: same mailbox + display rules as Watch; Phone-specific SwiftUI families.

## Solution pieces (≤5)

### 1. Replace stub widget implementation
- **What:** Real Baby Care provider + entry views; remove ControlWidget + Live Activity from bundle.
- **Why:** Stub is not care status; gallery noise hurts day-to-day.
- **How:** Mirror Watch `BabyCareProvider` / intent pattern for iOS families. Other: keep Live Activity — non-goal.

### 2. Reuse shared display + mailbox
- **What:** Load DTO → snapshot → `BabyCareComplicationDisplay.resolve`.
- **Why:** One ruleset for Auto priority, color, deep link page.
- **How:** Call Shared from Phone Widgets target membership. Other: fork display logic — drift risk.

### 3. Dual WidgetCenter reload
- **What:** Persist reloads Watch kind **and** Phone kind.
- **Why:** Today only `BabyCareComplication` reloads — Phone stays stale.
- **How:** Constants for both kinds; `reloadTimelines` twice (or array). Best: named constants in Shared.

### 4. iOS family layouts
- **What:** systemSmall + systemMedium layouts for timer / last care.
- **Why:** Home Screen glance surfaces (Gate A #1/#2).
- **How:** Phone-only SwiftUI using display model; medium may show secondary next-feed when idle. Large optional.

### 5. Tests + entitlements verify
- **What:** Unit: forbiddenKeys, display resolve (existing), Phone kind constant reload helper; build Phone Widgets.
- **Why:** No-token + stale-reload are top risks.
- **How:** Extend Watch AppTests / shared tests; CLI xcodebuild.

## Spike notes

- `BabyCareComplicationDisplay` already in `BabyCareShared` — Phone Widgets can reuse without Watch target.
- Watch intent/enums live in `MyBaby Watch Widgets/BabyCareWidgets.swift` — Phone needs parallel AppIntent (or move enum to Shared).
- `persistStatusForWidgets` → `WidgetCenter.shared.reloadTimelines(ofKind: "BabyCareComplication")` only — confirmed gap for Phone.
- Entitlements already list App Group on Phone App + Widgets.

## Reusable patterns

| Pattern | Where |
|---------|--------|
| App Group mailbox | `BabyCareStatusStore` |
| Display resolve | `BabyCareComplicationDisplay` |
| Timeline policy | `BabyCareWidgetTimeline` |
| Watch widget | `BabyCareWidgets.swift` |
| Deep link | `BabyHomeDeepLink` |

## System shape candidates

1. **Phone-only WidgetKit UI + Shared display/mailbox** — recommended.
2. **Force one shared WidgetKit view module for Watch+Phone** — heavy; families differ.
3. **Live Activity instead of Home Screen** — fails permanent glance job.

## Design tree (frontier)

| ID | Decision | Depends on | Status |
|----|----------|------------|--------|
| N1 | Phone widget `kind` string (new vs reuse Watch kind) | — | open |
| N2 | Families: small+medium only vs also large | — | open |
| N3 | Care-type AppIntent: duplicate in Phone vs move shared | — | open |
| N4 | Strip ControlWidget + Live Activity from bundle? | — | open |

## Has API / Has DB (refine)

- **Has API:** **no**
- **Has DB:** **no**

## Enough to design?

**yes** — after Grill settles N1–N4.
