# Security lens: watch-api-base-url

**Result:** clean
**Updated:** 2026-09-24

| OWASP | Check | Status |
|-------|-------|--------|
| A01 | Bearer Baby-grant token; no cookie session | OK |
| A02 | Token in Keychain; URL in UserDefaults; token not logged | OK |
| A03 | JSONSerialization for body; URL validate http(s) + host | OK |
| A04 | User-chosen URL — host shown on connect; HTTPS preferred | OK / accept risk |
| A05 | No blanket ATS allow-all; Local http documented for simulator | OK |
| A07 | UNAUTHORIZED / missing token → reconnect | OK |
| A09 | No Authorization logging observed | OK |

## Findings

| Severity | Finding | Suggestion |
|----------|---------|------------|
| Enhancement | User can point Watch at any host (SSRF from device to LAN) | Expected for self-hosted API; show host clearly (done) |

## Fix ask

(none)
