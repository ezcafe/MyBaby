# Idea: Phone M2 — Care home + quick-care

## Project shape (quick scan)

MyBaby Phone App (M1) already connects Offline (CloudKit `CareEvent`) or Cloud (GraphQL pair + token). Watch App already ships full care home: vertical pages Feed / Sleep / Diaper / Pump / Last care, driven by `BabyHomeStatusModel` with live `babyHomeQuickStatus` / `babyQuickCare` and Offline store writes. Phone home is still a placeholder (“Care logging comes in the next update”). my-apps defines the quick-care 80/20 in `docs/BABY_API.md` §4.

## Problem

After Connect, caregivers on iPhone cannot log feed, sleep, diaper, or pump. Watch has the day-to-day care loop; Phone does not. M1 shell alone does not finish the care-first ladder step.

## User / audience

- Parents / caregivers using iPhone as the main logging surface (one-handed, larger screen)
- Caregivers already on Offline with Watch who want the same iCloud care store on Phone
- Caregivers on Cloud who already paired and need the same quick-care rules as web `/baby` and Watch

## Outcome

**M2 only:**

1. Replace Phone home placeholder with a **care home** that can log: breast L/R (timers), formula/bottle amounts, sleep start/end, diaper kinds (+ dirty detail when needed), pump L/R timers and amount.
2. **Cloud mode:** status via `babyHomeQuickStatus`; writes via `babyQuickCare` with `clientRequestId` + fail/retry same id (BABY_API §4 / §7 / §10).
3. **Offline mode:** append/read via existing CloudKit Offline store; same chip behaviors without GraphQL; no fake “ok” when iCloud write fails.
4. Show last-care / open-nap / running timer state so the caregiver knows what is active.
5. Keep Settings leave + Connect from M1; do not ship widgets (M3) or activities/insights/growth (M4+).

## Metric

Connected Phone (Offline or Cloud): user can complete one breast timer save, one formula log, one sleep toggle, one diaper log, and one pump amount/timer path without leaving care home; fail shows chip/footer fail + Retry reuses same `clientRequestId` in live mode. Proven by unit tests on model/quick-care helpers (+ Offline append path); UI smoke on simulator.

## Sources (primary)

| Claim / topic | Primary source | Notes |
|---------------|----------------|-------|
| Quick-care 80/20 ops | `/Users/ptquang86/ws/my-apps/docs/BABY_API.md` §4, §7, §8, §10 | `babyHomeQuickStatus` + `babyQuickCare` |
| Watch care home UI | `MyBaby Watch App/Views/BabyHomeView.swift`, `Views/Pages/CarePages.swift` | Vertical pages + Retry |
| Care model / timers / fail | `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | Timed chips, retry same id |
| Shared page ids / snapshot | `BabyCareShared/BabyHomePage.swift`, `BabyHomeStatusSnapshot.swift`, `CareGuide*.swift` | Reuse |
| Offline store | `BabyCareShared/CloudKitOfflineCareStore.swift`, `OfflineCareStore.swift` | Same container as Watch |
| Phone shell today | `MyBaby Phone App/PhoneHomeView.swift`, `PhoneSessionModel.swift` | Placeholder to replace |
| Program ladder | `.my-docs/workflow/phone-app-parity/00-run.md` | M2 after M1 |

## Has UI

**yes** — Phone care home (feed / sleep / diaper / pump + last-care or status strip); fail/retry chrome; keep Settings gear from M1.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Prefer reusing Watch care model + page content adapted to iPhone (TabView or sections — Design picks). Match Watch chip labels and fail copy (“Failed”). Larger canvas may show more than one section without Watch’s vertical-page constraint — still keep #1/#2 dominant. Do not invent a new care ruleset.

## 80/20 UI (day-to-day)

### Main user goals

- Log breast L/R with timer start/stop
- Log bottle/formula amount quickly
- Start / end nap with clear open state
- Log diaper (wet/dirty/…) without hunting
- Log pump L/R or amount
- See when a send failed and retry once

### Vital few (high-impact ~20%)

- Care action chips (breast, bottle, sleep, diaper, pump)
- Running timer / open nap visibility
- Fail + Retry
- Last care / status glance

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Care logging controls for the current care type (chips)
- **Important info / action #2 (always visible):** Running timer or open nap state (or clear idle “Start nap”)
- **Core action placement:** Care home first screen after Connect; Settings secondary (gear)
- **Secondary actions:** Diaper dirty detail, Settings leave, mode label

### Top user journey to optimize

Open Phone (already Offline or Cloud) → see care home → tap breast Left → stop → save succeeds → status updates

### Sensible defaults

- Land on Feed (or Watch’s default page) after Connect
- Bottle amount chips match Watch/web presets
- Offline default session from M1 unchanged
- Retry reuses same `clientRequestId` on unknown/network fail (live)

### Biggest usability risks to fix first

- Placeholder home with no chips (cannot log)
- Live write fails silently (no fail chrome / no retry)
- Offline write looks OK but CloudKit rejected
- iPhone layout copies Watch vertical pages so poorly that chips are hard to hit

## Non-goals (M2)

- Home Screen widgets / Live Activities (M3)
- Activities list, Insights, Growth/vaccines, essays (M4+)
- New GraphQL fields or server changes (reuse BABY_API as-is)
- Merging Offline CloudKit history with live API history
- Redesigning Watch care UI
- Sample-mode full care polish (optional preview only)

## Assumptions to attack

- Phone can share `BabyHomeStatusModel` (or a thin Phone wrapper) without Watch-only imports — verify in Analyze
- iPhone should mirror Watch page set (Feed/Sleep/Diaper/Pump/Last) vs a single scrolling home — Design Decision
- Diaper dirty detail sheet parity is in M2 (not deferred) — default **yes** (Watch parity)

## Success criteria

- [ ] Placeholder copy gone; care actions usable Offline and live
- [ ] Live: status load + quick-care + fail/retry with same clientRequestId
- [ ] Offline: append/fetch CareEvent; fail surfaces to user
- [ ] Settings leave still returns to Connect
- [ ] Unit tests cover model quick-care / retry / offline append paths used by Phone
- [ ] No new server API; no widgets

## Open questions

1. iPhone navigation: vertical page TabView (Watch) vs segmented / single scroll — Design Decision
2. How much of `BabyHomeStatusModel` moves into `BabyCareShared` vs Phone-local wrapper — Analyze
3. Whether Last care is a fifth page or a header strip on Phone — Design

## Blocking questions

None — proceed to Gate A.
