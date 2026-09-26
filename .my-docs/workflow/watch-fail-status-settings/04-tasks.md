# Tasks: watch-fail-status-settings

**Mode:** full  
**Build must match:** `ui-refs/_proposed-*.html`

## Task 1 — Failing tests (S)

**Acceptance:**
- `BabyHomePage.allCases` ends with `.settings`; query `settings`; `shouldMount` ±1 includes settings neighbors.
- Live send fail sets `lastFailedControl` + `statusFail`.
- Success / new action clears fail for that control.
- `logout` clears token store + `isConnected == false`.
- Footer still prefers recovery → statusFail → tip.

**TDD notes:** Red first with stub GraphQL throwing.

## Task 2 — Model fail control + logout (M)

**Acceptance:**
- `CareFailedControl` (or equiv) set from `sendQuickCare` / mapped actions.
- `logout(tokenStore:)` clears Keychain, nils client, sample/live reset to disconnected.
- Auth disconnect does not leave live client usable.

**TDD notes:** Green Task 1 model cases.

## Task 3 — Chip / grid fail chrome (M)

**Acceptance:**
- TimedCareChip / ml / diaper show **Failed** + danger styling when model marks that control (match HTML).
- Other chips unchanged; done-flash does not hide active fail incorrectly.

**TDD notes:** Prefer view-model unit over UI snapshot; assert phase helpers if extracted.

## Task 4 — Settings page last (S)

**Acceptance:**
- `SettingsPage` in TabView after Last care; host line + Log out only (no Reconnect).
- Log out calls model logout; ContentView shows Connect.
- Deep link `page=settings` optional.

**TDD notes:** Page order + query tests.

## Task 5 — Connect guide + gate (S)

**Acceptance:**
- Quick connect guide **below** Save & connect (match `_proposed-connect-guide.html`).
- No “Continue with sample” on connect (Gate A2).
- After logout, care unreachable until successful Save & connect.

**TDD notes:** Gate/isConnected tests; guide presence can be manual / string constant test.

## Task 6 — Smoke (S)

**Acceptance:** Watch unit tests + build green; note in `06-test-log.md`.

## Out of scope

- Server/API/DB changes
- Widget logout
- Redesigning all care tips
