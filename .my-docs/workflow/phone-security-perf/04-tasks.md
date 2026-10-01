# Tasks: phone-security-perf

**Design option:** Option 1 (pending Gate B)  
**TDD:** yes — failing unit tests before production changes

## Task 1 — https-except-loopback URL policy

- **Acceptance:** `normalize` / `saveBaseURL` accept `http://127.0.0.1:3000` and `http://localhost:3000`; reject `http://example.com`; accept `https://example.com`. Redeem path rejects non-https non-loopback `baseURL` from server (via same normalize).
- **Tests (TDD):**
  - Unit: loopback http OK; non-loopback http nil/false; https OK.
  - Unit: `connectWithPastedCredentials` / pair success path still works with loopback http.
- **Files:** `BabyCareShared/BabyAPIConfig.swift`; tests in `MyBaby Watch AppTests`; `PhoneSessionModel` if redeem needs explicit re-normalize.

## Task 2 — Sanitize GraphQL Fail messages

- **Acceptance:** Unknown `.graphQL(message:)` does not put raw `message` into `statusFail`; UNAUTHORIZED/FORBIDDEN/401/403/missingToken/network keep current user strings.
- **Tests (TDD):**
  - Unit: model/helper maps generic GQL error → stable generic string (no substring from crafted message like `"secret=mny_x"`).
- **Files:** `BabyCareShared/BabyHomeStatusModel.swift` (and extract tiny mapper if cleaner).

## Task 3 — Offline fetch limit 80 + desiredKeys

- **Acceptance:** Offline refresh uses limit **80**; CloudKit fetch passes CareEvent field `desiredKeys` (not nil).
- **Tests (TDD):**
  - Unit: constant/helper for limit == 80 used by refresh path (or spy store records requested limit).
  - Unit: `makeRecord`/`event(from:)` still round-trip with listed keys.
- **Files:** `BabyHomeStatusModel.swift`; `CloudKitOfflineCareStore.swift`.

## Task 4 — Coalesce WidgetCenter reloads

- **Acceptance:** App Group save still immediate on `persistStatusForWidgets`; multiple rapid calls produce one reload wave within ~0.75s (test with fake clock / injectable coalescer).
- **Tests (TDD):**
  - Unit: coalescer records N schedule calls → 1 fire after window (use test double, not real WidgetCenter).
- **Files:** new small helper under `BabyCareShared/`; wire in `BabyHomeStatusModel.persistStatusForWidgets`.

## Task 5 — Smoke closeout

- **Acceptance:** Phone App (+ Widgets if needed) **BUILD SUCCEEDED**; existing unit suite green including new tests.
- **Tests:** Run unit test target used by repo; note build command in `06-test-log.md` later.

## Out of scope tasks

- Keychain ThisDeviceOnly; SecureField pairing code; certificate pinning; Watch-only chrome.
