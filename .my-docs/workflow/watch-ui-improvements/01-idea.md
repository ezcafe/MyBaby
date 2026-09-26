# Idea: Watch UI improvements pass

## Problem

Parents logging care on Watch hit unclear fail states (chip title becomes only “Failed”; footer Retry never wired), no visible live loading, a sixth Settings swipe page that duplicates the gear, cramped type/hit targets on Connect, and small polish gaps (Pump tip twice, bare ml numbers, logout without confirm).

## User / audience

Parents (and caregivers) using **MyBaby Watch** one-handed for quick care logs and reconnect/logout.

## Outcome

Care pages keep chip identity on fail, show Retry when a send fails, show a quiet live updating cue, and Settings lives only in a **gear sheet** (host + Log out with confirm + Reconnect). Connect and care chrome meet Watch readability and 44pt hit rules. Pump tip, ml labels, Last care lines, and a11y labels are cleaned up.

## Metric

Manual + unit: fail → Retry works; fail chip still shows which control; no Settings page in TabView; gear sheet has host / Log out / Reconnect; Connect presets ≥44pt; live load shows progress affordance.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** yes — primary surfaces: (1) gear Settings sheet, (2) fail chip + footer Retry, (3) Connect preset/error polish if needed in one HTML
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Log feed / sleep / diaper / pump with one tap
- See and fix a failed send without losing which chip failed
- Reconnect or log out without hunting a sixth swipe page

### Vital few (high-impact ~20%)

- Fail chip keeps identity + footer Retry
- Live updating cue
- Gear → Settings sheet (Option B) with Log out confirm + Reconnect

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Care chips on the current page (identity preserved even when failed)
- **Important info / action #2 (always visible):** Footer Retry when statusFail / recovery (or chip tap to retry)
- **Core action placement:** Controls stay primary; sheet holds session actions
- **Secondary actions:** Advanced connect paste; gear sheet host line; Reconnect opens Connect

### Top user journey to optimize

Raise wrist → care page → tap chip → (if fail) see Failed on same chip + Retry → success; or gear → Log out / Reconnect → Connect → back to care

### Sensible defaults

- Keep current care page strip order without Settings page: Feed · Sleep · Diaper · Pump · Last care
- Gear always available for session sheet
- After Log out → must Connect (existing gate)

### Biggest usability risks to fix first

- Fail title wipe (“Failed” only)
- Dead footer Retry
- Settings page + gear confusion
- Tiny Connect presets / 10pt guide type

## Non-goals

- Redesign care page IA beyond removing Settings page
- New API endpoints or pairing protocol
- Full widget redesign (live timeline only if low-cost; else defer)
- iPhone companion / QR pairing

## Locked decisions

| Decision | Choice |
|----------|--------|
| Settings redundancy | **Option B** — drop Settings TabView page; gear opens sheet: host + Log out (+ confirm) + Reconnect |

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| Gear sheet is enough for logout without a page | yes | Gate A day-to-day | Keep a thin Settings page |
| Reconnect = open Connect (same as gear today) | yes | Check ContentView | Separate reconnect path |
| Live ProgressView won’t fight TabView gestures | yes | Design note + test | Footer-only “Updating…” text |

## What we should not build

- Toasts/alerts stacked on top of chip fail
- Sample-mode shortcut after logout (must Connect)

## Success criteria

- [ ] Footer Retry (and Discard when recovery) wired on care pages
- [ ] Failed chips keep side/ml/diaper identity; Failed in subtitle
- [ ] Live status load shows progress / Updating cue
- [ ] No Settings in TabView; gear sheet: host, Log out (confirm), Reconnect
- [ ] Pump tip not duplicated; ml units; type ≥ caption2; presets ≥44pt; danger token on Connect errors; Last care ≤2 lines; basic a11y labels on chips

## Open questions

- Live widgets: include in this pass if App Group already exists; else defer (non-blocking).
- Page “1/5” cue: skip unless Gate A asks for it.
