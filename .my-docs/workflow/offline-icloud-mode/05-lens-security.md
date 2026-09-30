# Security lens: offline-icloud-mode

**Result:** ok  
**Updated:** 2026-09-29

## Findings

None Critical/Major.

## Notes

- API token stays in Keychain (Cloud/live only).
- CareEvent / App Group mailbox have no token fields.
- iCloud unavailable surfaced to user (no silent “connected”).

## Round notes

- OWASP-relevant: secrets, auth surface for Offline.
