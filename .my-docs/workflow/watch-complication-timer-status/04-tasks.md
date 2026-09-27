# Tasks: watch-complication-timer-status

**Mode:** full  
**TDD:** failing tests before production for logic  
**UI lock:** Match approved `ui-refs/_proposed-complications.html`  
**Design:** Decision 1 Option 1  
**Has API:** no · **Has DB:** no

## Task 1 — Complication display model + tests (S)

**Acceptance:** Pure helper maps snapshot/DTO → `{ mode: running|idle, kind, startDate?, lastCareDate?, lastCareLabel, color: teal|red, deepLinkPage }`. Priority: nap → breast → pump when running; idle = latest care `at`; red when feed/diaper past recommendation interval.

**Tests (write first):**
- Running nap beats overdue/last care
- Running breast when no nap
- Running pump when no nap/breast
- Nap beats breast if both somehow set
- Idle picks latest among feed/nap/diaper/pump
- In-range → teal; past interval → red (kind label still non-empty)
- Deep link page matches kind

## Task 2 — CareGuide interval + mapper `at` (S)

**Acceptance:** Map GraphQL `lastFeed.at` (etc.) into snapshot dates; compute overdue/in-range using stage intervals (document seconds per `CareGuideStage` in code comments or small table). Populate fields widgets need without new API.

**Tests:** Parse ISO `at`; ageDays stage → interval; overdue true/false fixtures.

## Task 3 — Extend App Group DTO + persist all timers (M)

**Acceptance:** DTO carries running kind/start + last*At; `forbiddenKeys` still clean; `persistStatusForWidgets` on breast/pump start/stop (and nap as today) + after status load; `WidgetCenter.reloadTimelines`.

**Tests:** Round-trip suiteName; empty → sample; encode has no token keys; after breast **and pump** start save, load shows runningStartedAt; stop clears running.

## Task 4 — Widget UI all families (M)

**Acceptance:** circular / corner / rectangular / inline match Gate A2 HTML: live `Text(start, style: .timer)` when running; idle last care + teal/red; rectangular brand + primary + secondary. Timeline policy: reload on write; optional `.after` at overdue boundary — **not** 1 Hz entries.

**Tests:** Snapshot/helper-driven view model strings/colors (unit); existing timeline nap policy still compiles (adjust if openNap moves to running*).

## Task 5 — Samples + README note (S)

**Acceptance:** Sample snapshots cover running nap, idle in-range, idle overdue for previews; README one line: face shows live timers + last-care color.

**Tests:** Sample helpers used by widget placeholder paths.

## Security / UI checks

- [ ] App Group never stores API token / pairing code
- [ ] HTML parity teal/red + family layouts
- [ ] No emoji as sole product UI (SF Symbols as today)
- [ ] Color not sole cue (kind label/icon with red)

## Task 6 — Care type picker + deep link page (M)

**Acceptance:** Widget uses `AppIntentConfiguration` with Care type = Auto | Feed | Sleep | Diaper | Pump (default Auto). Fixed type shows only that family’s timer or last event; Auto keeps prior priority. Tap `widgetURL` opens matching page (fixed always that page; Auto follows resolved kind).

**Tests (write first):**
- Fixed pump ignores open nap; shows last pump + deep link `.pump`
- Fixed sleep shows nap timer + deep link `.sleep`
- Fixed feed shows breast when nap also open + deep link `.feed`
- Fixed diaper empty still deep-links `.diaper`
- Care type `fixedDeepLinkPage` mapping

## Out of scope

- APNs / silent push
- New GraphQL fields (use existing `at`)
- In-app chip chrome redesign
- New widget kinds (still one kind; config parameter only)