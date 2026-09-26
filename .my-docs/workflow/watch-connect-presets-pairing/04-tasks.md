# Tasks: Watch connect — presets + short pairing code

## Task 1: DB schema + migration `watch_pairing_code` (TDD)

**Description:**  
Add Drizzle table + migration for hashed pairing codes (user, workspace, hash, expires, consumed).

**Acceptance:**

- [ ] Migration applies cleanly
- [ ] `workspace_id` FK → `workspace.id`
- [ ] Unique/index on `code_hash`; index on `user_sub`
- [ ] Schema exported from `db/schema`

**Tests (TDD — what turns red first):**

- [ ] Schema/unit: insert + consume columns + FK present (or migration smoke)

**Files likely touched:**  
`db/schema/…`, `db/migrations/0044_watch_pairing_code.sql`, `db/schema/index.ts`

**Scope:** S · **Dependencies:** none

---

## Task 2: Pairing service mint + redeem (TDD)

**Description:**  
Pure/service: generate code, hash, mint for user+workspace, redeem validates TTL/single-use, creates Baby token via `createApiTokenForUser`, returns `{ baseURL, token }`. Optional revoke prior tokens named `Apple Watch` same user+workspace.

**Acceptance:**

- [ ] Mint returns plaintext once; DB stores hash only
- [ ] Mint invalidates prior unconsumed codes for same `user_sub` (max one active)
- [ ] Redeem success once; second redeem → `CONSUMED` (or `INVALID_CODE` if collapsed)
- [ ] Expired code → `EXPIRED`
- [ ] Unknown code → `INVALID_CODE`
- [ ] `baseURL` from `NEXT_PUBLIC_APP_URL` normalized
- [ ] Successful redeem **auto-revokes** prior `Apple Watch` tokens same user+workspace, then creates new

**Tests (TDD — what turns red first):**

- [ ] Unit with fake DB/deps: happy path, expired, reused, bad hash, invalidate-prior, auto-revoke
- [ ] Trim whitespace + uppercase normalize before hash/compare

**Files likely touched:**  
`lib/watch-pairing-service.ts`, `lib/watch-pairing-service.test.ts`

**Scope:** M · **Dependencies:** Task 1

**Security:** No logging of plaintext code after return or token; constant-time hash compare if feasible.

---

## Task 3: HTTP routes mint + redeem (TDD)

**Description:**  
`POST /api/watch/pair` (session) and `POST /api/watch/pair/redeem` (public + rate limit). Zod bodies; `{ error, code }` errors.

**Acceptance:**

- [ ] Unauth mint → `{ code: "UNAUTHORIZED" }`
- [ ] Mint without same-origin → rejected (mirror tokens)
- [ ] Redeem without/invalid code → `{ code: "INVALID_CODE"|"EXPIRED"|"CONSUMED"|"BAD_REQUEST" }`
- [ ] Rate limit → `{ code: "RATE_LIMITED" }` on redeem (and mint) abuse
- [ ] Success envelopes use `{ data: … }`

**Tests (TDD — what turns red first):**

- [ ] Route/handler unit or integration with mocked service — error codes + same-origin mint
- [ ] Oversized JSON body rejected (`readJsonBounded` pattern)

**Files likely touched:**  
`app/api/watch/pair/route.ts`, `app/api/watch/pair/redeem/route.ts`, validators

**Scope:** M · **Dependencies:** Task 2

---

## Task 4: Web Settings Watch pairing UI

**Description:**  
Watch pairing card near API tokens: Generate code, show code + expiry.

**Acceptance:**

- [ ] Generate shows code; refresh generates new
- [ ] Matches DESIGN_GUIDE (radii, tokens)
- [ ] Skeleton/loading parity if section loading

**Tests (TDD — what turns red first):**

- [ ] Component test: Generate → displays code from mocked fetch
- [ ] Expiry text visible after Generate

**Files likely touched:**  
`components/api-token-settings.tsx` or `components/watch-pairing-settings.tsx`, Settings page, tests

**Scope:** M · **Dependencies:** Task 3

**UI / mobile:** Large selectable code; ≥44px hit on Generate.

---

## Task 5: Watch `WatchPairClient` + Production origin (TDD)

**Description:**  
Redeem client + `BabyAPIConfig.productionPairingOrigin` / Production preset sets bootstrap origin. Persist redeem `baseURL` + Keychain token.

**Acceptance:**

- [ ] Production preset sets pairing origin constant
- [ ] Redeem maps JSON to baseURL+token
- [ ] Errors map to short user strings

**Tests (TDD — what turns red first):**

- [ ] Stub URLSession: URL path, body `{code}`, success decode, 4xx failure

**Files likely touched:**  
`BabyCareShared/WatchPairClient.swift`, `BabyAPIConfig.swift`, tests

**Scope:** M · **Dependencies:** none (can parallel server after contract known)

---

## Task 6: Watch `AuthConnectView` code-first UI

**Description:**  
Pairing code primary; Local/Production presets; Advanced paste disclosure; wire Save & connect to redeem then `useLive`.

**Acceptance:**

- [ ] Matches 01b order: presets → code → Save → sample → advanced
- [ ] Successful redeem enters live + loads status
- [ ] Invalid code shows banner
- [ ] Local + advanced paste still works for sim (**does not call redeem**)

**Tests (TDD — what turns red first):**

- [ ] ViewModel/helper tests for connect paths; UI test if harness allows
- [ ] Advanced paste path skips `WatchPairClient.redeem`

**Files likely touched:**  
`MyBaby Watch App/Views/BabyHomeView.swift` (`AuthConnectView`), model hooks, README

**Scope:** M · **Dependencies:** Task 5

**UI / mobile:** Large targets; demote paste.

---

## Task 7: Docs — BABY_API + MyBaby README

**Description:**  
Document web Generate → Watch code → connect; Local/advanced; Production origin config.

**Acceptance:**

- [ ] Primary path is pairing, not paste
- [ ] Links routes and Keychain note

**Tests:** doc assert test optional (pattern from hardening docs tests)

**Files likely touched:**  
`docs/BABY_API.md`, `MyBaby/README.md`

**Scope:** S · **Dependencies:** Tasks 3–6

---

## Task order

1 → 2 → 3 → 4 (web)  
5 → 6 (Watch; can start after API contract stable)  
7 last  

## Has API / Has DB

- **Has API:** yes  
- **Has DB:** yes
