# Light repo skim: watch-connect-presets-pairing

**Result:** done  
**Updated:** 2026-09-26  
**Size:** ≤ ~40 lines — constraints only (not full analysis)  
**Note:** main-thread fallback — usage limit

## Project shape

MyBaby Watch: sample + live GraphQL care via `AuthConnectView` → `BabyAPIConfig` / Keychain → `BabyGraphQLClient` → my-apps `POST /api/graphql/baby`. my-apps: Settings API tokens (`mny_…`, Baby grant); no Watch pairing code today.

## Related existing UI / screens

| Path | What it does | Reuse? |
|------|--------------|--------|
| `MyBaby Watch App/Views/BabyHomeView.swift` → `AuthConnectView` | Local/Production presets, URL + token fields, Save & connect, sample | Primary Watch surface to extend |
| `BabyCareShared/BabyAPIConfig.swift` | Normalize origin, GraphQL URL, presets | Keep; redeem fills base URL |
| `BabyCareShared/BabyAPITokenStore.swift` (Keychain) | Persist `mny_…` | Keep after redeem |
| `components/api-token-settings.tsx` + Settings page | Create/list/revoke tokens | Add Watch pairing mint UI nearby |
| `app/api/tokens/route.ts`, `lib/api-token-service.ts` | Token CRUD | Pairing mint/redeem nearby pattern |

## Related APIs / data

| Path or route | Notes |
|---------------|-------|
| `POST /api/graphql/baby` + Bearer | Unchanged live care path after connect |
| `db/schema/api-token.ts`, migrations | Existing tokens; pairing may need new table |
| `docs/BABY_API.md` | Auth + Watch MVP steps — update after pairing |

## Hard constraints (do not fight)

1. No iPhone required; laptop/web OK to show code.
2. Presets + short code primary; long paste secondary.
3. Token in Keychain only; never log secrets.
4. ATS / HTTPS for production; Local `127.0.0.1` simulator-only.
5. DESIGN_GUIDE on web; Watch keep existing clean-minimal palette.

## Risks if we ignore the repo

- Duplicate auth beside existing token service
- Break live care by changing GraphQL instead of connect-only
- Leave paste as dominant Watch UI (defeats Option 5)
- Store pairing secrets in UserDefaults

## Enough for UI concept / Analyze?

**yes** — Watch connect + Settings tokens paths located; pairing API/DB shape for Analyze/Design.
