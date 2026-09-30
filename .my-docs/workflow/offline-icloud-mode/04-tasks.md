# Tasks: offline-icloud-mode

**Mode:** full  
**Has API:** no · **Has DB:** yes  
**UI:** Build must match `ui-refs/_proposed-connect-offline.html` + `_proposed-connect-cloud.html`

## Task 1 — Connect modes + Cloud URL default (S) — TDD

**Acceptance:**
- Connect shows **Offline | Cloud** only (Offline first); no Local chip.
- Default selection Offline; Offline hides URL + pairing; primary **Start Offline**.
- Cloud shows URL prefilled `http://127.0.0.1:3000` (`localPreset`); pairing; **Save & connect**.
- Pure helpers/tests for: default mode; Cloud default URL; URL field visibility (Cloud only).

**TDD:** Failing tests for preset/visibility/default URL before UI wiring.

## Task 2 — CareDataMode.offline + session restore (S) — TDD

**Acceptance:**
- `CareDataMode.offline`; `useOffline()` sets connected, clears GraphQL client.
- Persist/restore last mode; cold start Offline without token.
- Logout from Offline → Connect (`isConnected = false`); iCloud events not deleted.
- Auth gate: Offline does not show Connect.

**TDD:** Model + restore unit tests first.

## Task 3 — CareEvent model + OfflineSnapshotProjector (M) — TDD

**Acceptance:**
- Shared `CareEvent` value type + schemaVersion 1 fields per Design.
- Pure `OfflineSnapshotProjector.make(events:now:ageDays:)` covers last feed/nap/diaper/pump, open nap, running timer (vital last-* fields locked by tests).
- In-memory `OfflineCareStoring` fake for tests.

**TDD:** Projector + fake store tests red→green before CloudKit.

## Task 4 — CloudKit OfflineCareStore + entitlements (M)

**Acceptance:**
- CloudKit private DB implementation of `OfflineCareStoring` (append + fetch recent).
- Capability / container **`iCloud.vn.in4.MyBaby`** documented in README (companion join contract); if Xcode assigns a different id, update README + design note in same PR.
- Errors mapped to user-visible Offline status (no silent success).
- No tokens in records.

**TDD:** Protocol tests with fake; CloudKit path smoke/manual + error mapping units where pure.

## Task 5 — Wire chips to Offline writes (M) — TDD

**Acceptance:**
- When `mode == .offline`, timed stops / bottle / diaper / pump amount append events then refresh snapshot + App Group.
- Live mode unchanged (GraphQL).
- Sample/previews unchanged.

**TDD:** Model tests with fake store asserting append + snapshot update.

## Task 6 — README + Connect guide copy (S)

**Acceptance:**
- README: Offline first; Local removed; Cloud URL default; iCloud container + CareEvent contract for companions.
- Connect help steps updated (no Local; Offline default).

## Task 7 — Smoke (S)

**Acceptance:** Unit suite green for new tests; note smoke in `06-test-log.md` later.

## Checkpoints

| After | Check |
|-------|--------|
| Tasks 1–2 | Connect HTML parity + Offline session |
| Tasks 3–5 | Offline log → snapshot → widgets path |
| Task 6–7 | Docs + green units |

## Out of scope

- iOS/iPad/Mac companion UI
- Merging Offline ↔ live server history
- my-apps API/DB changes
- Full conflict-resolution UI
