# Code review log: watch-connect-presets-pairing

**Updated:** 2026-09-26  
**Note:** main-thread review (usage limit)

## Adversarial

**Result:** clean (after Fix)

| Severity | Finding | Status |
|----------|---------|--------|
| Major | Redeem revoked Watch tokens before create — create failure left user with no token; revoke-by-name would also kill new token | **fixed** — create then revoke with `excludeTokenId` |

## Quality

**Result:** clean

- Matches design Option 1: presets + pairing code primary; advanced paste secondary.
- System design honored (hashed codes, token factory, Watch pair client).
- DisclosureGroup removed (unavailable on watchOS) → toggle advanced paste.

## Merged SPM

### API (`05-lens-api` inline)

**Result:** clean  
Mint/redeem envelopes `{ data }` / `{ error, code }`; same-origin mint; rate limits; Zod edges.

### DB (`05-lens-db` inline)

**Result:** clean  
`watch_pairing_code` FK + unique hash; write owner = pairing service.

### Security

**Result:** clean  
Hashed codes; Keychain token; no token logging; TTL + single-use; rate limit redeem.

## Fix ask

None remaining.

## Round notes

- Build draft + smoke-pass; redeem order fixed; unit tests green.
