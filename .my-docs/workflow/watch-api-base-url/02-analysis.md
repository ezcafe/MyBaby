# Analysis: Configurable API base URL + Watch GraphQL client

**Size:** Prefer bullets. ≤5 solution pieces.

## Deep dive (required)

### Overall

#### What is this?
Let the caregiver set and save the Baby API **base URL** (and Bearer token) on Watch, then use a minimal GraphQL client so care status/logging can hit `POST {BASE_URL}/api/graphql/baby` instead of sample-only / a future hardcoded host.

#### Why do we need this?
Without a editable base URL, local vs production backends need rebuilds. Without a client, the URL setting does nothing. Sample mode alone cannot verify connectivity or log real care.

#### How to do this?
- Persist base URL + token; build endpoint as `{normalizedBase}/api/graphql/baby`.
- Thin `URLSession` GraphQL POST with `Authorization: Bearer mny_…`.
- Map `babyHomeQuickStatus` → `BabyHomeStatusSnapshot`; care taps call `babyQuickCare` then refresh status (or optimistic local + refresh).
- Keep sample/bypass path when not configured or when user chooses sample.
- **Other ways:** Settings-only (rejected — Decision 1 Option 2). Full Swift GraphQL codegen / Apollo (heavier than needed). iPhone Settings transfer for URL/token (better typing later; not required if presets + paste work).
- **Best practices:** Follow `docs/BABY_API.md` (Bearer Baby grant, `clientRequestId` retry, day window). Token in Keychain; URL in AppStorage/UserDefaults. ATS exception only if local HTTP is in scope. Reuse existing snapshot + side-effect model; do not invent REST.

### Solution pieces

#### 1. API config store (URL + token)

##### What is this?
Persisted settings: base origin, optional default presets, Bearer token.

##### Why do we need this?
Single source for every network call; survives relaunch.

##### How to do this?
- Approach: `BabyAPIConfig` (baseURL string + validation) in `BabyCareShared` or Watch Models; `@AppStorage` / UserDefaults for URL; Keychain for token.
- Other ways: Info.plist-only (not user-editable); compile-time XCConfig (dev-only).
- Best practices: Normalize trailing slash; store origin only (not full GraphQL path); never log token.

#### 2. Connect / settings UI

##### What is this?
Replace/extend `AuthStubView` so user can set URL + token and Continue (live or sample).

##### Why do we need this?
Watch has no settings screen today; auth stub is the natural gate.

##### How to do this?
- Approach: Fields for URL (TextField + presets: Local / Production), token (secure field), Save + Continue with sample.
- Other ways: Deep link `mybaby://config?base=…&token=…` from iPhone Notes (secondary).
- Best practices: Show current base; validate URL before save; clear error on bad URL.

#### 3. GraphQL HTTP client

##### What is this?
POST JSON `{ query, variables }` with Bearer header; decode data / GraphQL errors.

##### Why do we need this?
Contract is GraphQL-only (`BABY_API.md`); no Baby REST tree.

##### How to do this?
- Approach: Small `BabyGraphQLClient` protocol + `URLSession` impl; inject base URL + token from config.
- Other ways: Apollo/Swift GraphQL codegen — reject for MVP size.
- Best practices: Map HTTP + `errors[].extensions.code`; surface `x-request-id` when present; unit-test request URL building with mock session.

#### 4. Status map + quick-care wire

##### What is this?
Fetch `babyHomeQuickStatus`; mutate via `babyQuickCare`; keep local timer UX.

##### Why do we need this?
Option 2 requires live proof; BABY_API Watch 80/20 is status + quick-care.

##### How to do this?
- Approach: Day window helper (local midnight → next); map `summary` / open sleep / bottle chips into snapshot; on care save send mutation with new `clientRequestId`, retry same id on unknown failure; refresh status after success.
- Other ways: Status-only first (weaker Option 2). Parallel full offline queue (defer).
- Best practices: Mirror web documents in `lib/baby-query-options.ts`; keep local side effects for sample mode; live mode trusts server endNap rules after mutation.

#### 5. ATS / local HTTP

##### What is this?
Allow `http://` to local dev host when needed.

##### Why do we need this?
Local my-apps is often `http://127.0.0.1:3000` (simulator) or LAN IP (device).

##### How to do this?
- Approach: Document simulator → host machine URL; optional narrow ATS exception for local only if product needs device→LAN HTTP.
- Other ways: HTTPS-only + ngrok/tunnel (safer default).
- Best practices: Prefer HTTPS production default; do not open arbitrary ATS for all HTTP.

## What exists today

UI-first Watch: sample `BabyHomeStatusSnapshot`, local timers in `BabyHomeStatusModel`, `AuthStubView` stub, `bypassAuth: true` in `MyBabyApp`. No GraphQL client, no Keychain token, no base URL setting. Contract lives in my-apps `docs/BABY_API.md`.

## Dependencies

- my-apps Baby GraphQL must be reachable with Baby-grant Bearer token (no server schema change).
- Snapshot / care UI continue to work in sample mode.
- Unrelated WIP (`watch-feed-pump-merge`) may touch care pages — avoid merge conflicts on shared files when possible.

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `MyBaby Watch App/Views/BabyHomeView.swift` | `AuthStubView` to extend |
| `MyBaby Watch App/Models/BabyHomeStatusModel.swift` | Live vs sample care actions |
| `BabyCareShared/BabyHomeStatusSnapshot.swift` | Map GraphQL → UI model |
| `BabyCareShared/CareSideEffects.swift` | Local rules vs server after mutation |
| `Config/WatchApp-Info.plist` | ATS / URL types |
| `/Users/ptquang86/ws/my-apps/docs/BABY_API.md` | Endpoint, auth, ops, documents |
| `/Users/ptquang86/ws/my-apps/lib/baby-query-options.ts` | Canonical query/mutation strings |
| `/Users/ptquang86/ws/my-apps/lib/baby-home-day-window.ts` | Day window for status |

## Reusable patterns (prefer in Design)

| Pattern / name | Where it lives | Why Design should reuse it |
|----------------|----------------|----------------------------|
| Auth gate + stub | `ContentView` / `AuthStubView` | Natural place for URL/token UI |
| Snapshot + model | `BabyHomeStatusSnapshot` / `BabyHomeStatusModel` | Keep UI; swap data source |
| Local care side effects | `CareSideEffects` | Sample mode parity |
| BABY_API MVP ops | `BABY_API.md` §4 | Status + quick-care only |
| Bearer `mny_` + Baby grant | `BABY_API.md` §2 | Watch auth path |

## System shape candidates

| Concept | Fit |
|---------|-----|
| Config store → Client → Model → Views | Clear ownership; testable client |
| Protocol-based GraphQL client | Mock in unit tests |
| Sample vs Live mode flag | Safe fallback when offline / misconfigured |

## Spike notes

None run. Contract and repo scan sufficient for Design.

## Has API / Has DB (for parent)

- **Has API:** **no** — Watch client only; consumes existing `POST /api/graphql/baby` (no server contract change).
- **Has DB:** **no** — Keychain / UserDefaults only; no my-apps schema.

## Open questions (non-blocking for Design)

1. Default production base URL string (real deploy host) — set in Design as placeholder if unknown.
2. Device LAN HTTP vs HTTPS-tunnel for local — Design can default HTTPS + optional ATS note.
3. Deep-link paste for token — nice-to-have; presets + TextField enough for MVP.

## Clarity check

Instructions clear enough to Design: **yes** (Decision 1 Option 2 locked; BABY_API MVP ops = status + quick-care).
