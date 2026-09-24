# Tasks: Configurable API base URL + Watch GraphQL client

## Task 1: BabyAPIConfig + URL normalize (TDD)

**Description:**
Add pure `BabyAPIConfig` helpers: normalize origin, build GraphQL endpoint, validate http(s) absolute URL. Persist base URL via AppStorage/UserDefaults key. Default + Local/Production preset constants.

**Acceptance:**

- [x] Trailing slash stripped; endpoint is `{base}/api/graphql/baby`
- [x] Empty / relative / non-http(s) rejected
- [x] Presets return expected Local URL

**Tests (TDD — what turns red first):**

- [x] `normalize` strips slash and path junk policy (origin only)
- [x] `graphqlURL` appends `/api/graphql/baby` once
- [x] invalid strings fail validation

**Files likely touched:**
`BabyCareShared/BabyAPIConfig.swift` (or Watch Models), `MyBaby Watch AppTests/…`

**Scope:** S

**Dependencies:** none

---

## Task 2: Keychain token store (TDD)

**Description:**
Save/load/clear Bearer token in Keychain. Thin wrapper; never log secret.

**Acceptance:**

- [ ] Round-trip save → load returns same string
- [ ] Clear removes token
- [ ] Missing key returns nil

**Tests (TDD — what turns red first):**

- [ ] Keychain round-trip (or protocol fake if Keychain flaky in unit target)

**Files likely touched:**
`BabyCareShared/BabyAPITokenStore.swift`, tests

**Scope:** S

**Dependencies:** none

---

## Task 3: GraphQL client + request building (TDD)

**Description:**
Protocol + `URLSession` client: POST JSON `{query,variables}`, Authorization Bearer, decode `data` / `errors`. Inject base URL + token.

**Acceptance:**

- [ ] Request URL equals config graphql URL
- [ ] Header `Authorization: Bearer …` set when token present
- [ ] GraphQL `errors` surface as typed failure (code when present)

**Tests (TDD — what turns red first):**

- [ ] Mock `URLProtocol` / stub session asserts URL + headers + body keys
- [ ] Error payload maps to failure

**Files likely touched:**
`BabyCareShared/BabyGraphQLClient.swift`, tests

**Scope:** M

**Dependencies:** Task 1, Task 2

---

## Task 4: Status mapper + day window (TDD)

**Description:**
Port day-window idea (local midnight → next). Map `babyHomeQuickStatus` JSON → `BabyHomeStatusSnapshot` (summaries, open nap, recentBottleMl → chips via existing builders, age from birthDate when possible, tips via CareGuide).

**Acceptance:**

- [ ] Fixture status JSON maps last* summaries and openSleep
- [ ] Day window `dayFrom < dayTo` and ~24h span
- [ ] Missing fields produce safe empty lines (not crash)

**Tests (TDD — what turns red first):**

- [ ] Mapper fixture → snapshot equality on key fields
- [ ] Day window bounds

**Files likely touched:**
`BabyCareShared/BabyHomeStatusMapper.swift`, `BabyLocalDayWindow.swift`, tests

**Scope:** M

**Dependencies:** Task 3

---

## Task 5: Connect UI (URL + token)

**Description:**
Replace stub copy in `AuthStubView` with presets (Local / Production empty), URL field, token field, Save & connect, Continue with sample. Set **`MyBabyApp` / production `ContentView(bypassAuth: false)`**; previews keep `bypassAuth: true`. Add always-visible **Settings** from care home to reopen connect.

**Acceptance:**

- [ ] Cold start without bypass shows connect when not connected
- [ ] User can save URL + token and enter live gate
- [ ] Continue with sample still works without token
- [ ] Invalid URL shows clear error; does not connect live
- [ ] Settings from home reopens connect after sample/live

**Tests (TDD — what turns red first):**

- [ ] Config save helpers covered in Task 1–2; gate logic test: bypass false + not connected → show connect (if extractable)

**Files likely touched:**
`MyBaby Watch App/Views/BabyHomeView.swift`, `ContentView.swift`, `MyBabyApp.swift`

**Scope:** M

**Dependencies:** Task 1, Task 2

**UI / mobile:** presets first; large controls; show host clearly.

---

## Task 6: Live model — status load + quickCare (TDD)

**Description:**
When live: load status on appear. Apply **Live care call rules** from `03-design.md`: timer **start** local-only; **stop**/formula/pump amount/diaper/sleep → `babyQuickCare` with new `clientRequestId`; unknown failure retries **same** id; then refresh status. Sample mode keeps local `CareSideEffects` path. Surface statusFail on network/auth errors.

**Acceptance:**

- [ ] Live load replaces snapshot from client
- [ ] Breast/pump start does not call client; stop sends `breastRunning` when required
- [ ] Formula/diaper/sleep/pump amount send correct action kinds (per BABY_API)
- [ ] Retry helper reuses same `clientRequestId`
- [ ] Sample mode unchanged when not live
- [ ] `bypassAuth` previews still sample

**Tests (TDD — what turns red first):**

- [ ] Model with stub client: load status updates snapshot
- [ ] Start breast → zero client calls; stop breast → one BREAST with breastRunning
- [ ] `clientRequestId` retry helper keeps same id across retry

**Files likely touched:**
`MyBaby Watch App/Models/BabyHomeStatusModel.swift`, tests

**Scope:** M

**Dependencies:** Task 3, Task 4, Task 5

**Security:** no token in logs; map UNAUTHORIZED to reconnect.

---

## Task 7: ATS / README

**Description:**
Document Local vs Production URLs. Prefer HTTPS default. Add narrow ATS exception only if required for device LAN HTTP; otherwise document simulator `127.0.0.1` + tunnel for device.

**Acceptance:**

- [ ] README explains how to set base URL + create `mny_` Baby token
- [ ] ATS change justified or deferred with note

**Tests:** none (docs) — manual verify connect against local my-apps when available

**Files likely touched:**
`README.md`, `Config/WatchApp-Info.plist` (if needed)

**Scope:** S

**Dependencies:** Task 5

---

## Checkpoints

After Tasks 1–3:

- [ ] Config + client unit tests pass

After Tasks 4–6:

- [ ] Mapper + model stub-client tests pass
- [ ] Connect UI reachable; sample path still works

After Task 7:

- [ ] README usable for first live connect
