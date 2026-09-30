# Workflow run: offline-icloud-mode

**Status:** paused — Gate C

**Mode:** full

**Complexity:** complex — Offline/iCloud on Watch + Cloud (live API) connect; companion UI deferred

**Review profile:** full

**SPM plan:** db+security

**Last stage:** Gate C — paused (human merge approve)

## Resolved models

| Tier | Slug | Notes |
|------|------|-------|
| High | `composer-2.5-fast` | Preferred High/Medium unavailable → Fast |
| Medium | `composer-2.5-fast` | Medium → Fast |
| Fast | `composer-2.5-fast` | |

## Repo

- **Root:** `/Users/ptquang86/ws/apple/MyBaby`
- **Reference:** `/Users/ptquang86/ws/my-apps`
- **Branch:** `main`
- **Started:** 2026-09-29
- **Last stage:** Gate C — paused
- **Has UI:** yes
- **Has API:** no
- **Has DB:** yes
- **UI concept skip:** none

## Orchestrator card (parent — avoid re-ingest)

| Field | Value |
|-------|-------|
| Phase | merge |
| Next step | Gate C — human approve merge |
| Task description | (human gate) |
| Stage id | gate-c |
| stages.md section | my-merge-workflow |
| Model tier | n/a |
| Prereq Result | smoke-pass; review clean; full unit success |
| Artifact to check | `06-test-log.md`, `05-review-log.md` |
| Main-thread fallback | Build through review (usage limit) |

## Gates

- [x] Gate A — Round 2 ok 2026-09-29
- [x] Gate A2 — approved 2026-09-29 · ui-refs server stopped — Gate A2 approved
- [x] Gate B — approved 2026-09-29 (incl. Cloud rename)
- [ ] Gate C — Merge

## Notes

- Decision 1 Option 1: Watch + iCloud contract only
- Connect: Offline \| Cloud; Offline default; Cloud URL = `http://127.0.0.1:3000`
- CloudKit container `iCloud.vn.in4.MyBaby` — enable in Apple Developer / Xcode signing
- Draft: AuthConnectView, CareDataMode.offline, OfflineCareStore, CloudKitOfflineCareStore, projector, README

## Run log

- **19:08** · done · Step 0 — Classify · Mode full
- **19:09** · done · Step 1 — Ideation · main-thread · Has UI yes
- **19:15** · done · Decision 1 Option 1 · Gate A ok
- **19:21** · done · Gate A2 — approved
- **19:22** · done · Analyze → Design → reviews · TDD review
- **19:26** · done · Gate B — approved (Cloud rename)
- **19:30** · done · Step 4 — Build · main-thread · TDD Connect + Offline store
- **19:34** · done · Step 4s — Smoke · smoke-pass (build-for-testing + unit)
- **19:35** · done · Code review · clean · SPM db+security · main-thread
- **19:35** · done · Full test · unit success (Watch e2e N/A; CloudKit manual)
- **19:35** · paused · Gate C — Merge
