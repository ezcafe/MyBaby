# Analysis: Watch connect — presets + short pairing code

**Size:** Prefer bullets. ≤5 solution pieces.  
**Note:** main-thread fallback — usage limit after Task retry. Gate A2 approved.

## Deep dive (required)

### Overall

#### What is this?
Upgrade Watch connect so **Local preset** stays one-tap, and **live Production** uses a **short pairing code** (typed on Watch) that redeems over HTTPS for **base URL + Bearer `mny_…`**. No iPhone required; laptop/web shows the code.

#### Why do we need this?
Long URL + token paste on Watch fails often. Skipping pairing keeps the painful path and blocks reliable live care without Continuity Keyboard / iPhone.

#### How to do this?
- Web (signed-in): mint short-lived code → show on Settings.
- Watch: enter code → `POST` redeem on a **known bootstrap origin** → save origin + token (Keychain) → existing GraphQL live path.
- Local preset: keep for simulator; token paste secondary for Local/advanced.
- **Other ways:** iPhone companion (rejected — no iPhone); deep link with raw token (weaker); Watch-generated code entered on web (also fine, but UI concept locked web-mint / Watch-enter).
- **Best practices:** Hash codes at rest; single-use + TTL; create Baby-scoped token via existing `createApiTokenForUser`; never log secrets; reuse `AuthConnectView` / `BabyAPIConfig` / Keychain.

### Solution pieces

#### 1. Pairing code store + mint/redeem API (my-apps)

##### What is this?
Server table + routes: create code (session auth), redeem code (public, rate-limited) → `{ baseURL, token }` once.

##### Why do we need this?
Watch cannot invent credentials; web session owns workspace/Baby grant.

##### How to do this?
- Approach: new `watch_pairing_code` (hashed code, userSub, workspaceId, expiresAt, consumedAt); mint under Settings; redeem creates `mny_…` with Baby grant via `createApiTokenForUser`.
- Other ways: store plaintext code (bad); bind existing token id without new secret (Watch never gets `mny_…` string unless re-shown — worse UX).
- Best practices: rate-limit redeem; audit mint/redeem; return `NEXT_PUBLIC_APP_URL` (or request origin) as `baseURL`.

#### 2. Web Settings — Watch pairing panel

##### What is this?
UI near API tokens: Generate code, show large code + expiry.

##### Why do we need this?
Laptop is the mint surface (no iPhone).

##### How to do this?
- Approach: extend Settings / `ApiTokenSettings` area with Watch pairing card (01b).
- Other ways: separate `/settings/watch` page (more nav).
- Best practices: DESIGN_GUIDE tokens; code selectable; no token secret on this card (only short code).

#### 3. Watch AuthConnectView — presets + code primary

##### What is this?
Connect UI: Local/Production presets; pairing code field; Save & connect; sample; advanced paste secondary.

##### Why do we need this?
Matches Gate A / A2; removes long typing as primary path.

##### How to do this?
- Approach: extend `AuthConnectView`; redeem client → then existing `useLive` + Keychain.
- **Bootstrap origin (chicken/egg):** Watch must know where to POST redeem before it has a saved base URL.
- Other ways: Continuity paste only (needs phone/Mac clipboard).
- Best practices: large hit targets; clear expired/invalid errors; demote paste.

#### 4. Bootstrap / Production origin for redeem

##### What is this?
Known HTTPS origin used only to call redeem (and often becomes saved baseURL).

##### Why do we need this?
Without it, Watch cannot POST the code.

##### How to do this?
See **Decision 1** below.

#### 5. Docs / README connect steps

##### What is this?
Update MyBaby README + `BABY_API.md` Watch connect section.

##### Why do we need this?
Users must know web → code → Watch order.

##### How to do this?
Replace “paste URL+token” as primary with pairing steps; keep Local/advanced notes.

## Decision 1: Where does Watch POST redeem?

### Option 1 — Built-in Production pairing origin (+ Local paste path)
- **What it is:** Ship a configurable constant / Production preset = public my-apps HTTPS origin. Pairing redeem hits `{that}/api/…`. Local still uses `127.0.0.1` + optional token paste.
- **Example:** Production preset → `https://app.example.com`; user enters `AB7K2Q` → redeem there → save returned baseURL+token.
- **Pros:** Matches Option 1+5; no iPhone; Local sim unchanged.
- **Cons:** Multi-stage hosts need preset or constant update.

### Option 2 — User still pastes only the origin once, then codes forever
- **What it is:** First connect: paste base URL only; later connects use code against that host.
- **Example:** Paste `https://app.example.com` once → later only codes.
- **Pros:** Flexible hosts without rebuild.
- **Cons:** Still one long paste; weaker than Option 5 for first-time.

### Recommendation
**Pick Option 1** — Production/bootstrap origin constant + Local paste; pairing is primary live path.

## Decision 2: Redeem creates new token vs binds existing

### Option 1 — Create new Baby token on redeem (recommended)
- **What it is:** Redeem calls `createApiTokenForUser` (Baby app, write scope, name e.g. `Apple Watch`).
- **Example:** Code redeemed → Watch receives fresh `mny_…` once.
- **Pros:** Fits existing token model; revoke in Settings.
- **Cons:** Many Watch reconnects → many tokens (mitigate: revoke prior Watch-named or document revoke).

### Option 2 — Code bound to pre-chosen token id
- **What it is:** User picks token on web; code only authorizes delivery of that secret (secret not re-readable today).
- **Example:** Impossible without storing plaintext secret or re-showing — conflicts with current hash-only storage.
- **Pros:** Fewer tokens if secrets were re-showable.
- **Cons:** Does not fit current `api_token` hash design.

### Recommendation
**Pick Option 1**.

## Reusable patterns

| Pattern | Path | Use |
|---------|------|-----|
| Token create/list/revoke | `lib/api-token-service.ts`, `app/api/tokens/route.ts` | Redeem creates token |
| Settings tokens UI | `components/api-token-settings.tsx` | Host pairing card |
| Watch config + Keychain | `BabyAPIConfig`, `BabyAPITokenStore` | Persist redeem result |
| Thin GraphQL client | `BabyGraphQLClient` | Unchanged after connect |
| Public app origin | `NEXT_PUBLIC_APP_URL` | Redeem `baseURL` |

## System shape candidates

1. **Mint (cookie session) → DB code → Redeem (public) → create token → Watch Keychain** — recommended.
2. GraphQL-only pairing mutations — heavier; Watch already uses REST-ish POST for GraphQL; keep small REST for pair.

## Spike notes

None.

## Settled for Design (defaults)

| Topic | Lock |
|-------|------|
| Decision 1 | Option 1 — bootstrap Production origin |
| Decision 2 | Option 1 — create token on redeem |
| Mint UI | Settings near API tokens |
| Code | Short alphanumeric, TTL ~10 min, single-use, hashed |
| Local | Preset + advanced/Local token paste OK |
| Has API | **yes** |
| Has DB | **yes** |

## Open questions (non-blocking)

1. Exact Production origin constant value for this user’s deploy (env / Info.plist) — set at Build.

## Settled after design-review Fix ask

- Auto-revoke prior `Apple Watch` tokens on redeem: **yes**
- Error `code` enum + `{ data }` envelopes locked in `03-design`
- Max one active pairing code per user (invalidate prior on mint)

## Has API / Has DB (recommendation for `00-run.md`)

- **Has API:** yes — mint + redeem HTTP contracts
- **Has DB:** yes — pairing code table (+ reuse `api_token` writes)

## Clear enough to design?

**yes** — Gate A2 + Decisions 1–2 recommended locks. Parent may proceed to Design.
