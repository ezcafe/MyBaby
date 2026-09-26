# Lens: security — watch-fail-status-settings

**Result:** clean  
**Updated:** 2026-09-26

- Logout clears Keychain via `BabyAPITokenStore.clear()`.
- Live client removed; care gated by `AuthGate` / `isConnected`.
- No new network trust boundaries; no secrets logged in new code.
- Token never shown on Settings (host only).
