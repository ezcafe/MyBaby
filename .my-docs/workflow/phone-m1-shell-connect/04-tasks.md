# Tasks: phone-m1-shell-connect

**Mode:** full · **Has UI:** yes · **Has API:** no · **Has DB:** yes

## Task list

### Task 1 — iOS Application target + entitlements

- **Acceptance:** Phone target is `com.apple.product-type.application` with SwiftUI `@main` App; links `BabyCareShared`; entitlements include `iCloud.vn.in4.MyBaby` + `group.vn.in4.MyBaby`; scheme launches the app (appex not required).
- **Tests (TDD):** Project/config assertion test or documented checklist + compile smoke; unit N/A for pbxproj — prefer small test that container id constant matches entitlements string.

### Task 2 — Thin `PhoneSessionModel` (connect / mode / leave)

- **Acceptance:** Model supports `useOffline`, live connect after token, `leave`, cold-start restore from `CareDataModeStore`; Offline fail does not set connected; leave Offline keeps CK data; leave live clears token.
- **Tests (TDD):** Unit tests with fake `OfflineCareStoring` + fake pair/token store — restore offline; restore live when token present; offline init failure; leave clears connected.

### Task 3 — Phone Connect UI (Offline | Cloud)

- **Acceptance:** Offline default; Cloud URL default local preset; Start Offline / Save & connect; Advanced paste secondary; no Local chip; errors visible.
- **Tests (TDD):** Unit tests for preset/URL visibility helpers if extracted; UI test optional smoke Connect appears.

### Task 4 — Placeholder home + Settings sheet

- **Acceptance:** After connect, placeholder copy (care next); Settings shows mode + iCloud status + Leave → Connect.
- **Tests (TDD):** Unit test Settings leave calls session.leave; snapshot/status string helper if any.

### Task 5 — Pair client wiring (Cloud)

- **Acceptance:** Redeem via `WatchPairClient`; success stores token + connects live; bad code shows error.
- **Tests (TDD):** Fake `WatchPairClienting` success/fail paths on session or connect coordinator.

### Task 6 — Docs / README note

- **Acceptance:** Short README (or existing) notes Phone Offline joins same container; M1 scope (no care/widgets).
- **Tests (TDD):** N/A

## Out of scope (do not build)

- Care chips / quick-care (M2)
- Phone widgets UI (M3)
- Insights/growth/activities (M4+)
- CloudKit schema changes
- my-apps API changes

## Implementation order

1 → 2 (red tests) → 5 → 3 → 4 → 6
