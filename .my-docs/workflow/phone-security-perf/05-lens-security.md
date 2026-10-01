# Security lens: phone-security-perf

**Result:** clean  
**Updated:** 2026-10-01

| OWASP-ish | Note |
|-----------|------|
| Cleartext URL | https-except-loopback in `BabyAPIConfig.normalize` |
| Error leakage | `BabyLiveStatusFailCopy` — no raw GQL message |
| Token storage | Keychain unchanged (ThisDeviceOnly deferred) |
| App Group | Still status-only; no token fields |
| Leave / logout | Still clears Keychain token |

No Critical/Major. No Fix ask.
