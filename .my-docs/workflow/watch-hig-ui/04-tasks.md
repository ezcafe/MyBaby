# Tasks: watch-hig-ui

**Mode:** full  
**TDD:** failing tests before production for logic  
**UI lock:** Match approved `ui-refs/_proposed-*.html`  
**Design:** Decision 1 Option 1

## Task 1 — Vertical page style + background helper (S)

**Acceptance:** TabView uses `.verticalPage`; each care page applies `containerBackground` from page/urgency helper; Feed first. Match feed/sleep HTML place cues.

**Tests:** Unit — background helper returns distinct colors/identifiers for feed vs sleep vs overdue feed; page order unchanged (5 cases).

## Task 2 — Feed Bottle sheet + Pump amount sheet (M)

**Acceptance:** Feed: L/R + Bottle (no inline ml grid); sheet shows 3 ml + Custom. Pump: L/R/Both + Amount sheet with ml grid + Custom. Match `_proposed-feed-vertical.html`. Care rules unchanged.

**Tests:** Unit — selecting bottle/pump ml still calls existing model APIs (extend existing select tests if needed). Optional UI test smoke later.

## Task 3 — Materials, toolbar ProgressView, Retry toolbar (S)

**Acceptance:** Idle chips use material/light surface; remove header “Updating…”; show ProgressView when `isStatusLoading`; fail shows Retry in bottom toolbar. Settings destructive role. Match chrome intent of HTML.

**Tests:** Unit — `isStatusLoading` still toggles around load; label helpers unchanged for fail identity.

## Task 4 — Last care infographic (S)

**Acceptance:** Hero from `BabyCarePrimarySignal` (label + large value); then status rows. Match `_proposed-last-care.html` hierarchy.

**Tests:** Unit — hero copy helpers for open nap / next feed / overdue samples.

## Task 5 — App Group status store + live widgets (M)

**Acceptance:** Entitlements `group.vn.in4.MyBaby` on Watch app + widgets; `BabyCareStatusStore` write/read DTO; model writes after status load (+ nap signal changes); widgets timeline uses store with sample fallback; rectangular = primary + one secondary. Match `_proposed-complication-rect.html`.

**Tests:** Unit — store round-trip with injectable suiteName; empty store → sample fallback path; rectangular secondary picker logic; **DTO encode/decode never includes token or pairing code keys**.

## Task 6 — Short Connect + README (S)

**Acceptance:** Connect primary path only; Need help? disclosure holds steps + Advanced. README notes vertical Crown pages + live companions + Bottle sheet. Match `_proposed-connect-short.html`.

**Tests:** Unit — ConnectGuideCopy still available; optional helper `showsAdvanced` default false.

## Security / UI checks

- [ ] App Group never stores API token
- [ ] Logout still clears Keychain only via existing path
- [ ] HTML parity for Feed/Sleep/Last care/Connect/Complication
- [ ] Hits ≥44pt; no emoji product UI

## Out of scope

- New GraphQL / DB
- NavigationSplitView redesign
- Changing care side-effect rules
