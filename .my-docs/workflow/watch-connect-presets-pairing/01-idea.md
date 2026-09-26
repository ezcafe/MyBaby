# Idea: Watch connect — presets + short pairing code

## Project shape (quick scan)

MyBaby Watch already has live connect: `AuthConnectView` with Local/Production presets, URL field, `mny_…` SecureField, Keychain + GraphQL to my-apps `POST /api/graphql/baby`. my-apps issues Bearer tokens from **Settings → API tokens** (Baby grant). Long paste of production origin + token on Watch is the main pain.

## Problem

Parents (and the developer) must put a long API base URL and a long Bearer token onto Apple Watch. Typing or scribbling those strings is slow and error-prone. Paste helps but still needs another device clipboard and is awkward without iPhone. Connect should stay Watch-usable without an iPhone.

## User / audience

- Parents / caregivers using MyBaby Watch for live care logging
- Developer switching Local simulator vs deployed my-apps

## Outcome

1. **Presets (Option 1):** One-tap host presets remain (at least **Local** = `http://127.0.0.1:3000` for simulator).
2. **Short pairing code (Option 5):** Primary live path — user sees a short code on a **laptop/web** screen (logged-in my-apps), types only that short code on Watch; Watch exchanges it over HTTPS for **base URL origin + Bearer token**; stores token in Keychain and connects live.
3. Sample mode and Settings gear to reopen connect stay.
4. Long URL + full token paste is **secondary / advanced** (or Local-only), not the main journey.

## Metric

User completes live connect by entering a short pairing code (plus optional Local preset) without typing a full `https://…` origin or full `mny_…` on Watch; status load succeeds via existing Baby GraphQL; config survives relaunch. Proven by unit + focused Watch/API tests.

## Has UI

**yes** — Watch connect screen + web surface that shows/creates the pairing code (likely Settings / API tokens area).

## Lean / skip hints

- **Lean UI concept?** yes — one primary Watch connect surface + one small web “Watch pairing” strip/panel
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Connect Watch to the correct Baby API without long typing
- Keep care logging usable (sample or live) after connect / disconnect

### Vital few (high-impact ~20%)

- Host **presets** (Local for simulator)
- **Enter pairing code** + Connect on Watch
- **Show pairing code** on web (laptop) while signed in
- Clear current host / connected state on Watch
- Continue with sample

### Primary UI — core actions dominant

- **Important info / action #1 (always visible on Watch):** Pairing code entry + Connect
- **Important info / action #2 (always visible on Watch):** Presets (Local; Production if needed) + current host / status
- **Core action placement:** Extend existing `AuthConnectView` / Settings gear path; web: near API tokens / Watch connect
- **Secondary actions:** Advanced paste URL+token; Continue with sample; clear / disconnect — quieter or expand

### Top user journey to optimize

Web (laptop): create/show short code → Watch: open connect → (optional Local for sim) → enter code → Connect → care home live

### Sensible defaults

- Default to pairing-code path for Production/live
- Local preset still one tap for simulator
- Sample remains available without any code
- Codes expire quickly; failed code shows a short clear error

### Biggest usability risks first

- User does not know where to get the code on web
- Wrong / expired code looks like “app broken”
- Local vs pairing confusion on physical Watch
- Secret still ends up on clipboard if advanced paste remains

## Scope

- Watch: presets + short code field as primary connect; persist base URL + token as today
- my-apps: mint short-lived pairing code bound to user/workspace + Baby grant; redeem endpoint returns origin + token (or creates scoped token)
- Docs: README connect steps update
- Keep existing GraphQL live care path

## Non-goals

- iPhone companion / Continuity Keyboard as required path
- QR scan on Watch (no camera)
- Changing Baby GraphQL care schema
- Full Watch redesign beyond connect
- Deep link with raw token in URL as primary path

## Assumptions to attack

| Assumption | Must be true? | If false |
|------------|---------------|----------|
| Pairing code is minted on my-apps web while signed in (laptop OK, no iPhone) | Yes | Need another mint surface (CLI) — still no iPhone |
| Redeem returns base origin + usable `mny_…` (or equivalent) for Baby GraphQL | Yes | Watch cannot go live |
| Local preset can keep paste/manual token for simulator without pairing | Prefer yes | Local also needs pairing against a reachable host |
| Advanced paste URL+token can remain secondary | Prefer yes | Remove paste entirely if product wants code-only |

## Success criteria

- Watch connects live via short code without typing full URL or full token
- Local preset still works for simulator workflows
- Token stays in Keychain; never logged
- Sample mode still works offline
- Automated tests cover normalize/redeem client + server code mint/redeem rules

## Open questions

1. Mint UI: extend **Settings → API tokens** vs a dedicated “Connect Watch” panel? (Prefer tokens area + clear “Watch code” action.)
2. Redeem: create a **new** one-time-visible `mny_…` vs bind an **existing** token id? (Prefer create short-lived or standard token at redeem, show once never again on web.)
3. Code length / charset / TTL (e.g. 6–8 chars, ~5–10 min)?
4. Which origin the redeem returns — request Host / configured public app URL?

## Blocking questions

None — Gate A can proceed with Open questions deferred to Analyze/Design (prefer defaults above).
