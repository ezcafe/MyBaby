# Tasks: phone-m2-care-home

**Mode:** full · **Has UI:** yes · **Has API:** no · **Has DB:** no

## Task list

### Task 1 — Share care model + theme with Phone target

- **Acceptance:** `BabyHomeStatusModel` (and required helpers: CarePages dependencies, CareControls, BabyTokens, CarePageBackgroundFill, haptics stubs if needed) compile in **MyBaby Phone App**; WatchKit stays `#if os(watchOS)`; iOS build succeeds.
- **Tests (TDD):** Compile smoke; existing Watch unit tests still pass; add Phone-scheme or shared test target coverage for model init on iOS if feasible (else Watch tests remain source of truth for model).

### Task 2 — Wire `PhoneSessionModel` → `BabyHomeStatusModel`

- **Acceptance:** Connected Phone home creates/binds care model with live client or offline store; live loads status; leave tears down / returns Connect without leaking token.
- **Tests (TDD):** Unit: binding helper or session→model mode sync (fake client/store); live load called when mode live; offline does not call GraphQL.

### Task 3 — Phone care TabView shell (replace placeholder)

- **Acceptance:** Bottom tabs Feed / Sleep / Diaper / Pump / Last care; chips visible; Settings gear keeps M1 leave; Retry toolbar when fail; loading indicator when status loading.
- **Tests (TDD):** Unit for tab/page mapping if extracted; optional UI smoke “Feed” tab exists (skip if no Phone UITest target — note in log).

### Task 4 — Diaper detail + fail/retry parity

- **Acceptance:** Dirty/mixed opens detail sheet; live fail shows Failed + Retry same `clientRequestId`; offline write failure surfaces message.
- **Tests (TDD):** Extend/reuse Watch tests for retry id; add offline fail fake store test if not already covering Phone path.

### Task 5 — README / scope note

- **Acceptance:** README notes M2 care home (tabs + quick-care); widgets still later.
- **Tests (TDD):** N/A

## Out of scope (do not build)

- Phone widgets / Live Activities (M3)
- Activities / Insights / Growth (M4+)
- New GraphQL or CloudKit schema
- Watch UI redesign

## Implementation order

1 (compile) → 2 (red tests) → 3 → 4 → 5
