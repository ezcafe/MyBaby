# Tasks: Connect URL input + Local/Production active state

**Mode:** simple  
**Has API:** no · **Has DB:** no

## Task 1 — Preset resolver + failing tests (S)

**Acceptance:**
- Pure helper: normalized URL → `.local` / `.production` / `.none`.
- Local / production preset strings map correctly; empty / invalid / other → `.none`.

**TDD notes:** Red-first in `MyBaby_Watch_AppTests` before helper lands.

## Task 2 — Always-visible URL field + active presets (M)

**Acceptance:**
- Primary Connect: URL `TextField` **only when Production selected**; **hidden when Local** (default on load).
- On load: Local selected, `baseURL = localPreset`, URL field hidden.
- Local tap: Local selected, fills `localPreset`, hides URL field.
- Production tap: Production selected, **URL field cleared (empty)**, shows URL field.
- Advanced: token only.
- Save & connect uses `normalize(baseURL)`.

**TDD notes:** Resolver units cover selection; URL validate already in `BabyAPIConfig` tests — extend if redeem-guard changes.

## Task 3 — Smoke (S)

**Acceptance:** New unit tests green; note in `06-test-log.md` at smoke.

## Out of scope

- Shipping a fixed Production HTTPS default / plist value (still optional later)
- Connect layout redesign beyond URL field + preset chrome
- API / DB
