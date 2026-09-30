# Idea: Offline mode — iCloud care store on Watch (companion contract)

## Project shape (quick scan)

MyBaby is a watchOS Baby Care companion: Connect picks **Local** or **Production** API host, pairs to my-apps GraphQL, or uses **sample** in-memory data. Live care goes to the server; widget status uses App Group only (same Watch + widgets, not iCloud). There is no durable device-local / iCloud care log path yet, and no iPhone/iPad/Mac app target in this repo today.

## Problem

Parents who pick Local or Cloud must stay online and tied to the my-apps server. Sample mode is not real history — it does not persist care across relaunches. There is no **Offline** path that stores durable care in **iCloud** on Watch, ready for future Apple companions to join the same store.

## User / audience

- Parents / caregivers logging feed, sleep, diaper, pump on Watch without the web API
- Developers who still need Local / Cloud for live API testing
- Future companion apps (out of UI scope this pass) that will join the documented iCloud container

## Outcome

1. On Connect, user chooses peer modes **Offline | Cloud** (Offline first; **Local chip removed**).
2. Offline stores care events in an **iCloud-backed** store (user Apple ID) — durable, not sample memory and not App Group alone.
3. This pass ships **Watch only**: persist + sync-ready container; **document** the container/contract so later companions can join. No iPhone/iPad/Mac UI in this pass.
4. **Cloud** live API path remains; URL field defaults to the former local preset (`http://127.0.0.1:3000`). **sample** stays a separate non-durable preview (not Offline).
5. User sees Offline mode and plain iCloud status (signed in vs problem).

## Metric

User selects Offline on Connect, logs at least one care event without Cloud API credentials, data survives Watch app relaunch via the iCloud-backed store, and README/docs name the container + join rules for future companions. Proven by unit + focused Watch tests (iCloud sync may be mocked/harnessed).

## Has UI

**yes** — Watch Connect mode chooser (**Offline | Cloud**) + Offline / iCloud status; Settings may show mode + leave Offline. No companion app UI this pass.

## Lean / skip hints

- **Lean UI concept?** yes — Watch Connect mode row + short Offline status chrome only
- **Copy/token-only?** no

## Locked decisions (Decision 1 + Gate A / A2)

| Decision | Lock |
|----------|------|
| Share scope (Decision 1 → Option 1) | Watch Offline + iCloud contract only; companion UI deferred |
| Connect modes (Gate A2) | Peer modes **Offline \| Cloud** only — **Local chip removed**; Offline first (left + default) |
| Cloud URL default (Gate A2) | Cloud URL field defaults to former local preset `http://127.0.0.1:3000` |
| Rename (Gate B) | User-facing **Production** chip → **Cloud** (live API path; not Offline iCloud) |
| Offline vs sample | Offline = durable iCloud-backed care; sample = non-durable preview — never equate in copy |
| Label | Chips **Offline** + **Cloud**; Offline hint mentions iCloud |

## 80/20 UI (day-to-day)

### Main user goals

- Choose Offline when they want durable Watch care without the web server
- Trust logs survive relaunch (iCloud-backed)
- Use Cloud (URL defaults to local preset) when they need live API
- Understand companions are later (contract exists; no second app this pass)

### Vital few (high-impact ~20%)

- **Offline** first on Connect (default)
- Start Offline without pairing code / token
- Care writes persist via iCloud-backed store across relaunch
- Visible Offline / iCloud status
- **Cloud** with URL default `http://127.0.0.1:3000` (no Local chip)

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Mode chooser — Offline | Cloud (Offline first)
- **Important info / action #2 (always visible):** Mode-specific continue — Start Offline / Save & connect
- **Core action placement:** Two peer chips; Offline hides pairing code/URL; Cloud shows URL (default `http://127.0.0.1:3000`) + pairing
- **Secondary actions:** Need help / Advanced paste (Cloud only); iCloud troubleshooting in expand or Settings

### Top user journey to optimize

Open Connect → **Offline** (default) → Start Offline → log care → relaunch Watch → same data still there

### Sensible defaults

- **Offline** selected by default on Connect
- Offline does not require pairing code
- Cloud URL prefilled with `http://127.0.0.1:3000` (former Local preset)
- Prefer last-used mode on relaunch when safe

### Biggest usability risks to fix first

- Confusing Offline with sample
- Expecting Offline without iCloud account
- Over-promising live share on iPhone this pass — copy must say Watch + iCloud store; companions later
- Mixing Offline history with live API without clear rules (keep separate until Design)
- Developers looking for a “Local” chip — Cloud + default local URL replaces it

## Non-goals

- Companion iPhone / iPad / Mac UI in this pass
- Claiming live cross-device share UI as a shipped Outcome this pass
- Replacing my-apps Baby GraphQL for Local/Cloud API
- Full multi-writer conflict UI (document simple append / last-write rules)
- Android / non-Apple sync
- Migrating all server history into iCloud in v1
- Redesigning care chip pages beyond wiring Offline store
- Using App Group alone as the Offline store (App Group ≠ iCloud)

## Assumptions to attack

| Assumption | Risk if wrong | Fallback |
|------------|---------------|----------|
| iCloud-backed store works on watchOS for care logs | Sync lag / quota / sign-out | Show status; durable local cache still required |
| Documented container is enough for future companions | Companions need schema changes later | Version the care event document early |
| Sample can remain beside Offline | Users still pick sample by mistake | Demote sample once Offline is default for “no API” |
| Care event model maps without my-apps schema changes | Live vs Offline diverge | Map only quick-care fields Offline needs |

## What we should not build

- Server-side “offline” API on my-apps for this feature
- Token/pairing flow for Offline
- Companion app UI this pass

## Success criteria

- [ ] Connect offers peer modes Offline | Cloud (Offline first; no Local chip)
- [ ] Offline needs no pairing code / Bearer token; Offline is default selection
- [ ]Cloud URL defaults to `http://127.0.0.1:3000`
- [ ] Care events persist across Watch relaunch via iCloud-backed store
- [ ] Docs name iCloud container + join contract for future companions (no companion UI required)
- [ ] Clear UI when iCloud unavailable (cannot silently look “connected”)
- [ ] Copy distinguishes Offline (durable) from sample (preview)
- [ ]Cloud live path still works (pairing / advanced paste)
- [ ] Tests cover mode selection + persist/load Offline events

## Open questions (remaining for Design)

1. When switching Offline → live API, keep histories separate or attempt merge? (default: separate)
2. After Offline ships, demote or hide sample?
3. Exact CloudKit / SwiftData+CloudKit / other store choice — Analyze/Design

## Blocking questions

None.

## Round notes (Ideation update from Gate A)

- **2026-09-29:** User Decision 1 = Option 1 (Watch + contract only). Applied Gate A Fix ask: locked share scope, peer Offline mode, Offline ≠ sample; Outcome/Metric/Success no longer claim companion UI this pass. main-thread fallback (usage limit).
- **2026-09-29 Gate A2 feedback:** Offline first; remove Local chip; Cloud URL default = former local preset (`http://127.0.0.1:3000`).
- **2026-09-29 Gate B feedback:** Rename Production → **Cloud**.
