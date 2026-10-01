# Workflow run: phone-app-parity

**Status:** active — M3 Gate C (`phone-m3-widgets`); M1/M2 Gate C git still open (declined)

**Mode:** full

**Complexity:** complex — Phone app program; full my-apps Baby module end state; Offline iCloud; widgets; milestone ladder

**Review profile:** full

**SPM plan:** (set per milestone)

**Last stage:** Start M3 Ideation

## Resolved models

| Tier | Slug | Notes |
|------|------|-------|
| High | `composer-2.5-fast` | Preferred High/Medium missing → Fast |
| Medium | `composer-2.5-fast` | Preferred Medium missing → Fast |
| Fast | `composer-2.5-fast` | Available |

## Repo

- **Root:** `/Users/ptquang86/ws/apple/MyBaby` (primary). Learn from `/Users/ptquang86/ws/my-apps`.
- **Branch:** `main`
- **Started:** 2026-09-30
- **Has UI:** (per milestone)
- **Has API:** (per milestone)
- **Has DB:** (per milestone)
- **HITL Gate B:** blocking
- **HITL Gate C:** blocking
- **04a:** (per milestone)

## Settled decisions

| Decision | Pick | Lock |
|----------|------|------|
| Decision 1 | Option 1 — Care-first ladder | M1 shell+Connect → M2 care home → M3 widgets → M4+ web depth |
| Decision 2 | Option 2 — Full Baby web module | End state = home + care pages + activities + insights + growth + settings (M4 may split further) |

## Milestone map

| # | Slug | Scope | Status |
|---|------|--------|--------|
| M1 | `phone-m1-shell-connect` | Phone app shell; Connect Offline\|Cloud; pair; join iCloud container; Settings basics | **Gate C open** (shipped draft; git pending) |
| M2 | `phone-m2-care-home` | Care home + quick-care rules (Watch + my-apps §4) | **done local** (Gate C declined) |
| M3 | `phone-m3-widgets` | Home Screen widgets via App Group | **active** |
| M4+ | `phone-m4-*` (split later) | Full web depth: activities, insights, growth, settings, detail pages | pending |

## Orchestrator card (parent — avoid re-ingest)

| Field | Value |
|-------|-------|
| Phase | gate-c |
| Next step | User: approve M3 commit / push / PR / merge |
| Task description | Gate C for M3 |
| Stage id | gate-c |
| stages.md section | my-merge-subflow |
| Model tier | Fast |
| Prereq Result | M3 build+test pass · review clean |
| Artifact to check | `phone-m3-widgets/06-test-log.md` |
| Main-thread fallback | yes |

## Gates

- [x] Gate A — (M3)
- [x] Gate B — (M3) approved
- [ ] Gate C — (M3) blocking

## Notes

- Program end state is **full my-apps Baby module on Phone** (Decision 2 Option 2), delivered via care-first ladder (Decision 1 Option 1).
- M1/M2 Gate C git declined — proceed M3; do not commit without explicit yes.
- M4+ will be split into smaller runs after M3 (do not boil M4 in one pass).
- Watch Offline CloudKit + `BabyCareShared` remain source of truth for Offline join.
- Watch widgets/complications already use App Group mailbox — Phone M3 should mirror that pattern for Home Screen.

## Run log

- **18:18** · paused · Step 0 — Classify · waiting Decision 1 + Decision 2
- **19:05** · done · Decisions · D1 Option 1 · D2 Option 2 · start M1
- **19:10** · paused · M1 Gate B — blocking — see `phone-m1-shell-connect`
- **19:16** · paused · M1 Gate C — blocking — commit/push/PR/merge?
- **20:00** · done · Start M2 · `phone-m2-care-home` · Mode full · Review profile full
- **20:45** · done · M2 · Gate C declined · no git
- **20:46** · done · Start M3 · `phone-m3-widgets` · Mode full · Review profile full
- **20:51** · paused · M3 Gate B — blocking — see `phone-m3-widgets`
- **20:55** · paused · M3 Gate C — blocking — commit/push/PR/merge?
