# Tasks: watch-ui-improvements

**Mode:** full  
**TDD:** tests before or with each behavior change  
**UI lock:** Match approved `ui-refs/_proposed-*.html`

## Task 1 — Fail chip identity (S)

**Acceptance:** Timed / ml / diaper fail keeps identity title; subtitle `Failed`; no blank `" "` subtitle. Matches fail HTML.

**Tests:** Unit/UI helper or snapshot strings for fail label composition; extend existing bottle fail test expectations if they assert title.

## Task 2 — Store last payload + Retry/Discard (M)

**Acceptance:** On live send fail, store payload + clientRequestId; footer Retry retries same id; statusFail without chip Retry reloads status; Discard clears recovery when present. Care pages pass `onRetry`/`onDiscard`.

**Tests:** Unit — fail sets payload; retry calls same id; success clears fail + payload. (Extend `bottleSendFailSetsFailedControl`.)

## Task 3 — Live Updating cue (S)

**Acceptance:** During `loadLiveStatus`, muted “Updating…” (or ProgressView) visible under header; cleared when done/fail.

**Tests:** Unit — `isStatusLoading` true→false around load (mock client).

## Task 4 — Settings gear sheet Option B (M)

**Acceptance:** No Settings TabView page; gear opens sheet with host, Log out (confirm), Reconnect; Reconnect opens Connect; logout clears token and requires Connect. Deep link `settings` opens sheet. Match settings HTML.

**Tests:** Unit — `BabyHomePage` cases = 5 (or settings not in strip); deep link settings → sheet flag / selected stays last care or feed; logout still clears token. Update mount tests.

## Task 5 — Connect + type + ml polish (S)

**Acceptance:** Presets height 44; errors use danger; secondary ≥ caption2; ml chips show `N ml`; Pump tip not duplicated in header+footer; Last care `lineLimit(2)`; chip a11y labels. Match connect HTML.

**Tests:** Unit for ml label helper if extracted; ConnectHostURLField / preset height constant; Pump header detail ≠ pumpTip when tip used in footer.

## Task 6 — Docs / README (S)

**Acceptance:** README page map drops Settings page; notes gear sheet.

**Tests:** N/A

## Security / UI checks

- [ ] Logout confirm before clear token
- [ ] Sheet never shows raw token
- [ ] HTML parity: fail identity, Retry, sheet, Connect presets
- [ ] Hits ≥44pt on presets and sheet buttons

## Out of scope

- Live widgets timeline
- New API/DB
