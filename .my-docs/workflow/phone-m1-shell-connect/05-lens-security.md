# Security lens: phone-m1-shell-connect

**Result:** clean  
**Updated:** 2026-09-30

| OWASP-ish | Note |
|-----------|------|
| Token storage | Keychain via `BabyAPITokenStore` |
| Leave clears token | tested |
| ATS | Narrow localhost/127.0.0.1 only in Phone Info.plist |
| No secrets in App Group/CK | yes |
| Pair errors | no token echo in UI |

No Critical/Major. Enhancement: confirm Apple Developer portal capabilities for Phone app id (manual).

No Fix ask.
