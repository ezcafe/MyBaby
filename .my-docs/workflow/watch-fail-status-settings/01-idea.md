# Idea: Trigger fail status + Settings page + logout

## Problem

Two day-to-day gaps on MyBaby Watch:

1. **Hidden send failures** — When a live log (`babyQuickCare`) or status load fails, the app mostly shows a muted footer `statusFail` line. Parents looking at the **trigger buttons** they just tapped may not notice the fail. Errors feel easy to miss on a small Watch screen.
2. **Settings not a page** — Connect / credentials live behind the toolbar **gear** (overlay `AuthConnectView`). There is no last swipe page for Settings, and no clear **logout** (clear token / leave live) from care home.

## User / audience

Parents logging care on Apple Watch (sample or live against my-apps Baby GraphQL).

## Outcome

Done when:

1. After a failed live log/status send, the **trigger button(s) involved** show a clear **error status** (visible on the chip itself — not only the footer).
2. **Settings** is the **last** TabView page (after Last care): host/status + reconnect affordances as needed.
3. From Settings, user can **Log out** (clear stored token). After logout they **must Connect** again before care pages; connect screen shows a **quick guide**.
4. Existing care pages and footer priority (recovery → fail → tip) stay usable; fail-on-button complements footer, does not invent a second conflicting error language.

## Metric

- Unit: fail maps to button error state; logout clears token + live client; page order includes Settings last.
- Manual: tap log → forced fail → button shows error; swipe to Settings → Log out → connect/sample again.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** no — new Settings page + button fail chrome need Gate A2 HTML
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Know immediately when a care log failed to send (so they can retry).
- Reach Settings without hunting for the gear.
- Log out when switching devices / ending a live session.

### Vital few (high-impact ~20%)

- Error status **on the trigger that failed** (highest attention).
- Settings as last page + **Log out** action.
- Keep care logging taps fast (error state must not block the next tap permanently).

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Care trigger chips stay primary; on fail, the same chip shows error status (e.g. short “Failed” / retry cue) until cleared by retry or new success.
- **Important info / action #2 (always visible):** On Settings page — connection summary + **Log out**.
- **Core action placement:** Fail state on the chip the user just used; Settings last in swipe order; Log out prominent on Settings, not buried.
- **Secondary actions:** Full reconnect / pairing fields can stay on connect overlay or Settings advanced; gear may remain as shortcut to connect (Design decides keep vs drop).

### Top user journey to optimize

Live: Log bottle → send fails → **chip shows error** → tap again or Retry → success clears error → swipe to Settings → **Log out** when done.

### Sensible defaults

- Error state clears on successful resend or when user starts a new successful action on that control.
- Logout clears Keychain token and live client; force connect screen. After logout, no sample shortcut — user must Connect before care.
- Page order: Feed → Sleep → Diaper → Pump → Last care → **Settings**.

### Biggest usability risks to fix first

- Error only in muted footer (missed).
- Settings only via gear (easy to miss logout).
- Error state stuck forever or blocking taps.
- Logout unclear (token left in Keychain).

## Non-goals

- New server APIs or GraphQL schema changes.
- Redesigning all care chrome / tips.
- Widget / complication logout.
- Multi-account management.

## Assumptions to attack

| Assumption | Must be true? | Fastest way to kill it | If false, what changes? |
|------------|---------------|------------------------|-------------------------|
| “Trigger buttons” = timed chips + ml/diaper grids that fire live send | yes for UX | Confirm with user | Narrow which controls get fail chrome |
| Footer `statusFail` can stay as backup or become secondary | soft | Design | Drop footer fail if chip-only is enough |
| Logout = clear token + disconnect live (+ show connect) | yes | Code path check | Soft “use sample” only |

## What we should not build

- Toast / system Alert for every fail.
- New pairing protocol.
- Settings as a nested NavigationStack away from TabView.

## Success criteria

- [ ] Failed live send shows error on the relevant trigger control.
- [ ] Settings is last TabView page.
- [ ] Log out clears credentials and exits live session.
- [ ] Unit coverage for page order, fail→button state, logout clear.
- [ ] Gate A2 HTML approved for chip fail + Settings look.

## Open questions

- Keep toolbar gear after Settings page exists, or Settings-only entry?
- Chip error copy: “Failed” vs short reason (Unauthorized / Network)?
- ~~After logout~~ → **locked:** must Connect; quick guide on connect page; no Reconnect on Settings.
- Does status-load failure (no specific chip) still use footer only, or a page-level banner?

## Project shape (scan)

MyBaby is a watchOS care companion: TabView care pages + sample/live modes; live failures today set `statusFail` for muted `CareFooterSlot`; connect is `AuthConnectView` via gear / auth gate; token in Keychain via `BabyAPITokenStore`.
