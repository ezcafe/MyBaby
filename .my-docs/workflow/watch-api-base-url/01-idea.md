# Idea: Configurable API server URL (Watch)

## Problem

Caregivers (and the developer) need the Watch app to talk to a chosen Baby API host (local, staging, or production). Today there is no user-editable base URL; any future client would risk a hardcoded host.

## User / audience

Parents / caregivers using MyBaby Watch; developer switching between local and deployed my-apps backends.

## Outcome

User can view and change the API server base URL (and token as needed) in the app (persisted). A minimal Baby GraphQL client uses that base URL for live status and/or quick-care — not a compile-time-only host.

## Metric

User sets base URL (e.g. `http://127.0.0.1:3000` or production origin) + Bearer token; app can fetch live status via `POST {base}/api/graphql/baby` per `BABY_API.md`; value survives relaunch.

## Has UI

**yes**

## Lean / skip hints

- **Lean UI concept?** yes (1 primary surface — settings / connect)
- **Copy/token-only?** no

## 80/20 UI (day-to-day)

### Main user goals

- Point the Watch at the correct Baby API host
- Keep care logging usable after connect (sample or live)

### Vital few (high-impact ~20%)

- Edit and save API base URL
- Sensible default so first launch still works
- Clear current URL (readable on small Watch screen)

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Current API base URL (or “not set”)
- **Important info / action #2 (always visible):** Edit / Save (or confirm) base URL
- **Core action placement:** On connect/settings surface (extend existing auth stub), not buried in care pages
- **Secondary actions:** Reset to default; advanced notes (path suffix `/api/graphql/baby`)

### Top user journey to optimize

Open app → Connect/settings → see URL → edit → save → continue to care home

### Sensible defaults

Ship a default production (or documented) base URL; empty/invalid shows a clear error when live calls exist; sample mode remains usable offline.

### Biggest usability risks first

- Typing long URLs on Watch is painful
- Wrong URL looks like “app broken”
- Confusing base origin vs full GraphQL path

## Non-goals

- Changing my-apps GraphQL schema or routes
- Full Insights/timeline/growth client surface on Watch
- iPhone companion app (unless Analyze proves Watch-only text entry is impossible)

## Assumptions to attack

- There is already a hardcoded URL — quick scan found none; GraphQL client not wired; sample mode + auth stub only
- **Decision 1 locked:** Option 2 — settings + wire GraphQL client this run

## Success criteria

- Persisted user-editable API base URL (+ token for Bearer)
- Minimal live GraphQL client uses `{BASE_URL}/api/graphql/baby`
- Unit tests for URL resolve/validate + client request building
- Care home still works in sample/bypass mode when not connected

## Open questions

1. Prefer typing URL on Watch vs presets (local / production) + paste token?
2. MVP live ops: `babyHomeQuickStatus` only, or also `babyQuickCare` mutations this run?
